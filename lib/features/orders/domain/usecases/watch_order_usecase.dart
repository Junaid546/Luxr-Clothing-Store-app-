import 'package:dartz/dartz.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';
import 'package:style_cart/features/orders/domain/repositories/order_repository.dart';

class WatchOrderUseCase {
  final OrderRepository _repo;
  const WatchOrderUseCase(this._repo);

  Stream<Either<Failure, OrderEntity>> call(String orderId) =>
      _repo.watchOrder(orderId);
}
