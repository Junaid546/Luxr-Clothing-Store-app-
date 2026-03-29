import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/usecases/usecase.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';
import 'package:style_cart/features/orders/domain/repositories/order_repository.dart';

class UpdateOrderStatusParams extends Equatable {
  const UpdateOrderStatusParams({
    required this.orderId,
    required this.newStatus,
    required this.updatedBy,
    this.note,
    this.courier,
  });
  final String orderId;
  final String newStatus;
  final String updatedBy;
  final String? note;
  final CourierEntity? courier;

  @override
  List<Object?> get props => [orderId, newStatus, updatedBy];
}

class UpdateOrderStatusUseCase
    implements UseCase<void, UpdateOrderStatusParams> {
  const UpdateOrderStatusUseCase(this._repo);
  final OrderRepository _repo;

  @override
  Future<Either<Failure, void>> call(UpdateOrderStatusParams params) =>
      _repo.updateOrderStatus(
        orderId: params.orderId,
        newStatus: params.newStatus,
        updatedBy: params.updatedBy,
        note: params.note,
        courier: params.courier,
      );
}
