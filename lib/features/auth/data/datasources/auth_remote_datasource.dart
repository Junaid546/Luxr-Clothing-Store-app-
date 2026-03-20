import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

/// Abstract remote data source for authentication operations
abstract interface class AuthRemoteDataSource {
  /// Firebase Auth state changes stream
  Stream<User?> get firebaseAuthStateChanges;

  /// Sign in with email and password
  Future<UserModel> signInWithEmail(String email, String password);

  /// Register new user with email, password, and display name
  Future<UserModel> registerWithEmail(
    String email,
    String password,
    String displayName,
  );

  /// Sign in with Google OAuth
  Future<UserModel> signInWithGoogle();

  /// Sign out current user
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordReset(String email);

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Get user from Firestore by UID
  Future<UserModel> getUserFromFirestore(String uid);

  /// Create user document in Firestore
  Future<void> createUserInFirestore(UserModel user, Map<String, dynamic> data);

  /// Update last login timestamp
  Future<void> updateLastLogin(String uid);

  /// Update FCM token
  Future<void> updateFcmToken(String uid, String token);
}
