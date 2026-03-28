import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/core/usecases/usecase.dart';
import 'package:stylecart/features/orders/domain/entities/order_entity.dart';
import 'package:stylecart/features/orders/domain/repositories/order_repository.dart';

class UpdateOrderStatusParams extends Equatable {
  final String orderId;
  final String newStatus;
  final String updatedBy;
  final String? note;
  final CourierEntity? courier;

  const UpdateOrderStatusParams({
    required this.orderId,
    required this.newStatus,
    required this.updatedBy,
    this.note,
    this.courier,
  });

  @override
  List<Object?> get props => [orderId, newStatus, updatedBy];
}

class UpdateOrderStatusUseCase
    implements UseCase<void, UpdateOrderStatusParams> {
  final OrderRepository _repo;
  const UpdateOrderStatusUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(
    UpdateOrderStatusParams params,
  ) =>
      _repo.updateOrderStatus(
        orderId: params.orderId,
        newStatus: params.newStatus,
        updatedBy: params.updatedBy,
        note: params.note,
        courier: params.courier,
      );
}
