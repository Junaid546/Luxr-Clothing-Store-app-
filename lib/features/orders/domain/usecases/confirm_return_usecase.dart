import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/usecases/usecase.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';
import 'package:style_cart/features/orders/domain/repositories/order_repository.dart';

class ConfirmReturnParams extends Equatable {
  const ConfirmReturnParams({
    required this.orderId,
    required this.items,
    required this.adminId,
  });
  final String orderId;
  final List<OrderItemEntity> items;
  final String adminId;

  @override
  List<Object> get props => [orderId, items, adminId];
}

class ConfirmReturnUseCase implements UseCase<void, ConfirmReturnParams> {
  const ConfirmReturnUseCase(this._repo);
  final OrderRepository _repo;

  @override
  Future<Either<Failure, void>> call(ConfirmReturnParams params) =>
      _repo.confirmReturn(
        orderId: params.orderId,
        items: params.items,
        adminId: params.adminId,
      );
}
