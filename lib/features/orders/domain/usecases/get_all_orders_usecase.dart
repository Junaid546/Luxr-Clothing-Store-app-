import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/usecases/usecase.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';
import 'package:style_cart/features/orders/domain/repositories/order_repository.dart';

class GetAllOrdersParams extends Equatable {
  final String? statusFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int limit;
  final Object? lastDocument;

  const GetAllOrdersParams({
    this.statusFilter,
    this.fromDate,
    this.toDate,
    this.limit = 20,
    this.lastDocument,
  });

  @override
  List<Object?> get props => [statusFilter, fromDate, toDate, limit];
}

class GetAllOrdersUseCase
    implements UseCase<List<OrderEntity>, GetAllOrdersParams> {
  final OrderRepository _repo;
  const GetAllOrdersUseCase(this._repo);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(
    GetAllOrdersParams params,
  ) => _repo.getAllOrders(
        statusFilter: params.statusFilter,
        fromDate:     params.fromDate,
        toDate:       params.toDate,
        limit:        params.limit,
        lastDocument: params.lastDocument,
      );
}
