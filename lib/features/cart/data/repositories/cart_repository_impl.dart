// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/data/firestore_base_repository.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/cart/data/models/cart_item_model.dart';
import 'package:style_cart/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl extends FirestoreBaseRepository implements CartRepository {
  CartRepositoryImpl(super.firestore);

  @override
  Stream<Either<Failure, List<CartItemModel>>> watchCart(String userId) {
    return safeFirestoreStream(() =>
      firestore
        .collection(FirestoreConstants.users)
        .doc(userId)
        .collection(FirestoreConstants.cart)
        .orderBy('addedAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(CartItemModel.fromFirestore).toList()),
    );
  }

  @override
  Future<Either<Failure, void>> addToCart({
    required String userId,
    required CartItemModel item,
  }) {
    return safeFirestoreCall(() async {
      final cartRef = firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .collection(FirestoreConstants.cart);
          
      final docRef = cartRef.doc(item.cartItemId);
      final doc = await docRef.get();
      
      if (doc.exists) {
        await docRef.update({
          'quantity': FieldValue.increment(item.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.set(item.toFirestore());
      }
    });
  }

  @override
  Future<Either<Failure, void>> updateQuantity({
    required String userId,
    required String cartItemId,
    required int quantity,
  }) {
    return safeFirestoreCall(() async {
      final docRef = firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .collection(FirestoreConstants.cart)
          .doc(cartItemId);
          
      if (quantity <= 0) {
        await docRef.delete();
      } else {
        await docRef.update({
          'quantity': quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Future<Either<Failure, void>> removeFromCart({
    required String userId,
    required String cartItemId,
  }) {
    return safeFirestoreCall(() async {
      await firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .collection(FirestoreConstants.cart)
          .doc(cartItemId)
          .delete();
    });
  }

  @override
  Future<Either<Failure, void>> clearCart(String userId) {
    return safeFirestoreCall(() async {
      final cartRef = firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .collection(FirestoreConstants.cart);
      final docs = await cartRef.get();
      final batch = firestore.batch();
      for (final doc in docs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    });
  }

  @override
  Future<Either<Failure, int>> getCartItemCount(String userId) {
    return safeFirestoreCall(() async {
      final snap = await firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .collection(FirestoreConstants.cart)
          .count()
          .get();
      return snap.count ?? 0;
    });
  }
}

