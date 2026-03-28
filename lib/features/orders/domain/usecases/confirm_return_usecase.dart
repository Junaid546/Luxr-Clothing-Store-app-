import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/core/usecases/usecase.dart';
import 'package:stylecart/features/orders/domain/entities/order_entity.dart';
import 'package:stylecart/features/orders/domain/repositories/order_repository.dart';

class ConfirmReturnParams extends Equatable {
  final String orderId;
  final List<OrderItemEntity> items;
  final String adminId;

  const ConfirmReturnParams({
    required this.orderId,
    required this.items,
    required this.adminId,
  });

  @override
  List<Object> get props => [orderId, items, adminId];
}

class ConfirmReturnUseCase implements UseCase<void, ConfirmReturnParams> {
  final OrderRepository _repo;
  const ConfirmReturnUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(
    ConfirmReturnParams params,
  ) =>
      _repo.confirmReturn(
        orderId: params.orderId,
        items: params.items,
        adminId: params.adminId,
      );
}
