// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering

import 'package:fpdart/fpdart.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/cart/data/models/cart_item_model.dart';
import 'package:style_cart/features/orders/data/models/order_model.dart';

abstract interface class OrderRepository {
  Future<Either<Failure, void>> placeOrder({
    required String userId,
    required OrderModel order,
    required List<CartItemModel> cartItems,
  });

  Stream<Either<Failure, List<OrderModel>>> watchUserOrders(String userId);
  
  Future<Either<Failure, OrderModel>> getOrderById(String orderId);

  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? note,
    required String updatedBy,
  });
}

