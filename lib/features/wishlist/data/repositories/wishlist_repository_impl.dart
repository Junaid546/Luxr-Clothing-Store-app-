// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/data/firestore_base_repository.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:style_cart/features/wishlist/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl extends FirestoreBaseRepository implements WishlistRepository {
  WishlistRepositoryImpl(super.firestore);

  @override
  Stream<Either<Failure, List<WishlistItemModel>>> watchWishlist(String userId) {
    return safeFirestoreStream(() =>
      firestore
        .collection(FirestoreConstants.users)
        .doc(userId)
        .collection(FirestoreConstants.wishlist)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(WishlistItemModel.fromFirestore).toList()),
    );
  }

  @override
  Future<Either<Failure, void>> addToWishlist(String userId, WishlistItemModel item) {
    return safeFirestoreCall(() async {
      final batch = firestore.batch();
      final wishlistRef = firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .collection(FirestoreConstants.wishlist)
          .doc(item.productId);
      final userRef = firestore
          .collection(FirestoreConstants.users)
          .doc(userId);
      
      batch.set(wishlistRef, item.toFirestore());
      batch.update(userRef, {
        'wishlistCount': FieldValue.increment(1),
      });
      await batch.commit();
    });
  }

  @override
  Future<Either<Failure, void>> removeFromWishlist(String userId, String productId) {
    return safeFirestoreCall(() async {
      final batch = firestore.batch();
      final wishlistRef = firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .collection(FirestoreConstants.wishlist)
          .doc(productId);
      final userRef = firestore
          .collection(FirestoreConstants.users)
          .doc(userId);
      
      batch.delete(wishlistRef);
      batch.update(userRef, {
        'wishlistCount': FieldValue.increment(-1),
      });
      await batch.commit();
    });
  }

  @override
  Future<Either<Failure, bool>> isWishlisted(String userId, String productId) {
    return safeFirestoreCall(() async {
      final doc = await firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .collection(FirestoreConstants.wishlist)
          .doc(productId)
          .get();
      return doc.exists;
    });
  }

  @override
  Future<Either<Failure, void>> clearWishlist(String userId) {
    return safeFirestoreCall(() async {
      final wishlistRef = firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .collection(FirestoreConstants.wishlist);
      final docs = await wishlistRef.get();
      
      if (docs.docs.isEmpty) return;

      final batch = firestore.batch();
      for (final doc in docs.docs) {
        batch.delete(doc.reference);
      }
      
      final userRef = firestore
          .collection(FirestoreConstants.users)
          .doc(userId);
      batch.update(userRef, {
        'wishlistCount': 0,
      });

      await batch.commit();
    });
  }
}


