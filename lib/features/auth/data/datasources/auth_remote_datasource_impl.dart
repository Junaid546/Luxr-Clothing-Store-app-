import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// Implementation of AuthRemoteDataSource using Firebase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  const AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  // ── Firestore helper ────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(FirestoreConstants.users);

  // ── Auth state stream ────────────────────────────────────────
  @override
  Stream<User?> get firebaseAuthStateChanges => _auth.authStateChanges();

  // ── Sign In with Email ───────────────────────────────────────
  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;

      // Update lastLoginAt in background (non-blocking)
      unawaited(updateLastLogin(user.uid));

      return getUserFromFirestore(user.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── Register with Email ─────────────────────────────────────
  @override
  Future<UserModel> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      // 1. Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;

      // 2. Update display name in Firebase Auth profile
      await user.updateDisplayName(displayName);

      // 3. Build Firestore doc
      final docData = UserModel.newUserDoc(
        uid: user.uid,
        email: email,
        displayName: displayName,
      );

      // 4. Write to Firestore — use SET with merge:false
      //    so we never overwrite an existing admin doc
      await _usersRef.doc(user.uid).set(docData);

      // 5. Send email verification
      unawaited(user.sendEmailVerification());

      // 6. Return UserModel
      return getUserFromFirestore(user.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } on FirebaseException catch (e) {
      // Firestore write failed — roll back Auth account
      await _auth.currentUser?.delete();
      throw ServerException('Registration failed: ${e.message}. Please retry.');
    }
  }

  // ── Sign In with Google ─────────────────────────────────────
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException('Google sign-in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check if user doc already exists in Firestore
      final docSnap = await _usersRef.doc(user.uid).get();

      if (!docSnap.exists) {
        // New Google user — create Firestore doc
        final docData = UserModel.newUserDoc(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          photoUrl: user.photoURL,
        );
        await _usersRef.doc(user.uid).set(docData);
      } else {
        // Existing user — just update lastLoginAt
        unawaited(updateLastLogin(user.uid));
      }

      return getUserFromFirestore(user.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // ── Sign Out ────────────────────────────────────────────────
  @override
  Future<void> signOut() async {
    try {
      // Clear FCM token before sign out
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _usersRef.doc(uid).update({FirestoreConstants.fcmToken: null});
      }
      await GoogleSignIn().signOut();
      await _auth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── Get User from Firestore ─────────────────────────────────
  @override
  Future<UserModel> getUserFromFirestore(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        throw const NotFoundException(
          'User profile not found. Please contact support.',
        );
      }
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore error');
    }
  }

  // ── Create user doc ─────────────────────────────────────────
  @override
  Future<void> createUserInFirestore(
    UserModel user,
    Map<String, dynamic> data,
  ) async {
    await _usersRef.doc(user.uid).set(data);
  }

  // ── Update last login ───────────────────────────────────────
  @override
  Future<void> updateLastLogin(String uid) async {
    await _usersRef.doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'emailVerified': _auth.currentUser?.emailVerified ?? false,
    });
  }

  // ── Update FCM token ─────────────────────────────────────────
  @override
  Future<void> updateFcmToken(String uid, String token) async {
    await _usersRef.doc(uid).update({FirestoreConstants.fcmToken: token});
  }

  // ── Send password reset ─────────────────────────────────────
  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    }
  }

  // ── Send email verification ───────────────────────────────────
  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // ── Error mapper ─────────────────────────────────────────────
  String _mapFirebaseAuthError(String code) {
    return switch (code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password.',
      'invalid-credential' => 'Invalid credentials.',
      'email-already-in-use' => 'This email is already registered.',
      'weak-password' => 'Password is too weak.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Try again later.',
      'network-request-failed' => 'Network error. Check connection.',
      'invalid-email' => 'Invalid email format.',
      _ => 'Authentication error: $code',
    };
  }
}
