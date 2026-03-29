import 'package:dartz/dartz.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';
import 'package:style_cart/features/orders/domain/repositories/order_repository.dart';

class WatchUserOrdersUseCase {
  const WatchUserOrdersUseCase(this._repo);
  final OrderRepository _repo;

  Stream<Either<Failure, List<OrderEntity>>> call(String userId) =>
      _repo.watchUserOrders(userId);
}
