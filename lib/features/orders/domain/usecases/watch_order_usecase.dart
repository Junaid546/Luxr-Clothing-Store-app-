import 'package:dartz/dartz.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/features/orders/domain/entities/order_entity.dart';
import 'package:stylecart/features/orders/domain/repositories/order_repository.dart';

class WatchOrderUseCase {
  final OrderRepository _repo;
  const WatchOrderUseCase(this._repo);

  Stream<Either<Failure, OrderEntity>> call(String orderId) =>
      _repo.watchOrder(orderId);
}
