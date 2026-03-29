import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/usecases/usecase.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';
import 'package:style_cart/features/orders/domain/repositories/order_repository.dart';

class CancelOrderParams extends Equatable {
  const CancelOrderParams({
    required this.orderId,
    required this.userId,
    required this.items,
    this.reason,
  });
  final String orderId;
  final String userId;
  final List<OrderItemEntity> items;
  final String? reason;

  @override
  List<Object?> get props => [orderId, userId, items, reason];
}

class CancelOrderUseCase implements UseCase<void, CancelOrderParams> {
  const CancelOrderUseCase(this._repo);
  final OrderRepository _repo;

  @override
  Future<Either<Failure, void>> call(CancelOrderParams params) {
    if (params.orderId.isEmpty) {
      return Future.value(const Left(ValidationFailure('Invalid order ID')));
    }
    return _repo.cancelOrder(
      orderId: params.orderId,
      userId: params.userId,
      items: params.items,
      reason: params.reason,
    );
  }
}
