import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/usecases/usecase.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';
import 'package:style_cart/features/orders/domain/repositories/order_repository.dart';

class GetUserOrdersParams extends Equatable {
  final String userId;
  final String? statusFilter;
  final int limit;
  final Object? lastDocument;

  const GetUserOrdersParams({
    required this.userId,
    this.statusFilter,
    this.limit = 10,
    this.lastDocument,
  });

  @override
  List<Object?> get props => [userId, statusFilter, limit, lastDocument];
}

class GetUserOrdersUseCase
    implements UseCase<List<OrderEntity>, GetUserOrdersParams> {
  final OrderRepository _repo;
  const GetUserOrdersUseCase(this._repo);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(
    GetUserOrdersParams params,
  ) => _repo.getUserOrders(
        userId:       params.userId,
        statusFilter: params.statusFilter,
        limit:        params.limit,
        lastDocument: params.lastDocument,
      );
}
