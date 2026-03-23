// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering

import 'package:fpdart/fpdart.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/cart/data/models/cart_item_model.dart';

abstract interface class CartRepository {
  Stream<Either<Failure, List<CartItemModel>>> watchCart(String userId);
  Future<Either<Failure, void>> addToCart({required String userId, required CartItemModel item});
  Future<Either<Failure, void>> updateQuantity({required String userId, required String cartItemId, required int quantity});
  Future<Either<Failure, void>> removeFromCart({required String userId, required String cartItemId});
  Future<Either<Failure, void>> clearCart(String userId);
  Future<Either<Failure, int>> getCartItemCount(String userId);
}

