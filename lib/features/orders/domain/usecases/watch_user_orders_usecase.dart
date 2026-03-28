import 'package:dartz/dartz.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/features/orders/domain/entities/order_entity.dart';
import 'package:stylecart/features/orders/domain/repositories/order_repository.dart';

class WatchUserOrdersUseCase {
  final OrderRepository _repo;
  const WatchUserOrdersUseCase(this._repo);

  Stream<Either<Failure, List<OrderEntity>>> call(String userId) =>
      _repo.watchUserOrders(userId);
}
