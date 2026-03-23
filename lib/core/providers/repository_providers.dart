// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/features/cart/domain/repositories/cart_repository.dart';
import 'package:style_cart/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:style_cart/features/orders/domain/repositories/order_repository.dart';
import 'package:style_cart/features/orders/data/repositories/order_repository_impl.dart';
import 'package:style_cart/features/products/domain/repositories/product_repository.dart';
import 'package:style_cart/features/products/data/repositories/product_repository_impl.dart';
import 'package:style_cart/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:style_cart/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:style_cart/features/products/data/providers/product_data_providers.dart';

part 'repository_providers.g.dart';

@riverpod
FirebaseFirestore firestore(FirestoreRef ref) {
  return FirebaseFirestore.instance;
}

@riverpod
ProductRepository productRepository(
  ProductRepositoryRef ref,
) => ProductRepositoryImpl(
      ref.watch(firestoreProvider),
      ref.watch(imageRepositoryProvider),
    );

@riverpod
CartRepository cartRepository(CartRepositoryRef ref) =>
    CartRepositoryImpl(ref.watch(firestoreProvider));

@riverpod
WishlistRepository wishlistRepository(WishlistRepositoryRef ref) =>
    WishlistRepositoryImpl(ref.watch(firestoreProvider));

@riverpod
OrderRepository orderRepository(OrderRepositoryRef ref) =>
    OrderRepositoryImpl(ref.watch(firestoreProvider));
