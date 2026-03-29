import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/providers/firebase_providers.dart';
import 'package:style_cart/core/storage/secure_storage_service.dart';

part 'account_deletion_service.g.dart';

// Handles complete user account deletion.
// GDPR requires ability to delete all user data.
// Process:
//   1. Re-authenticate (recent auth required)
//   2. Delete all user's orders (mark as deleted)
//   3. Delete cart subcollection
//   4. Delete wishlist subcollection
//   5. Delete notifications
//   6. Delete user profile doc
//   7. Delete Firebase Auth account
//   8. Delete Storage files (profile photo)

class AccountDeletionService {
  const AccountDeletionService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _auth = auth,
       _storage = storage;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  Future<Either<Failure, void>> deleteAccount({
    required String userId,
    required String password,
    required String email,
    required SecureStorageService secureStorage,
  }) async {
    try {
      // Step 1: Re-authenticate (required for deletion)
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);

      // Step 2: Run deletion in parallel where possible
      await Future.wait([
        _deleteSubcollection(userId, FirestoreConstants.cart),
        _deleteSubcollection(userId, FirestoreConstants.wishlist),
        _deleteUserNotifications(userId),
      ]);

      // Step 3: Anonymize orders (never delete orders —
      // financial records must be kept)
      await _anonymizeOrders(userId);

      // Step 4: Delete Storage files
      await _deleteStorageFiles(userId);

      // Step 5: Delete Firestore user doc
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .delete();

      // Step 6: Delete Firebase Auth account (LAST)
      await _auth.currentUser!.delete();

      // Step 7: Clear local storage
      await secureStorage.clearAllSecure();

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return const Left(
          AuthFailure('Incorrect password. Account deletion cancelled.'),
        );
      }
      if (e.code == 'requires-recent-login') {
        return const Left(
          AuthFailure('Please sign in again before deleting your account.'),
        );
      }
      return Left(AuthFailure(e.message ?? 'Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Delete all docs in a user subcollection
  Future<void> _deleteSubcollection(String userId, String subcollection) async {
    final snap = await _firestore
        .collection(FirestoreConstants.users)
        .doc(userId)
        .collection(subcollection)
        .get();

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Delete user's notifications
  Future<void> _deleteUserNotifications(String userId) async {
    final snap = await _firestore
        .collection(FirestoreConstants.notifications)
        .where('userId', isEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Anonymize orders (GDPR: keep records, remove PII)
  Future<void> _anonymizeOrders(String userId) async {
    final snap = await _firestore
        .collection(FirestoreConstants.orders)
        .where('userId', isEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      final data = doc.data();
      batch.update(doc.reference, {
        'userEmail': '[DELETED]',
        'userName': '[DELETED]',
        'userId': '[DELETED-${userId.hashCode}]',
        'shippingAddress': {
          'fullName': '[DELETED]',
          'phone': '[DELETED]',
          'street': '[DELETED]',
          'city': data['shippingAddress']?['city'] ?? '',
          'state': data['shippingAddress']?['state'] ?? '',
          'zipCode': '[DELETED]',
          'country': data['shippingAddress']?['country'] ?? '',
        },
        'deletedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  // Delete profile photo from Storage
  Future<void> _deleteStorageFiles(String userId) async {
    try {
      final ref = _storage.ref().child('users/$userId');
      final list = await ref.listAll();
      await Future.wait(list.items.map((item) => item.delete()));
    } catch (_) {
      // Non-critical — continue with deletion
    }
  }
}

@riverpod
AccountDeletionService accountDeletionService(AccountDeletionServiceRef ref) =>
    AccountDeletionService(
      firestore: ref.watch(firestoreProvider),
      auth: ref.watch(firebaseAuthProvider),
      storage: ref.watch(firebaseStorageProvider),
    );
