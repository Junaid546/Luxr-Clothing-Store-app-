import 'package:dartz/dartz.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/core/usecases/usecase.dart';
import 'package:stylecart/features/orders/domain/entities/order_entity.dart';
import 'package:stylecart/features/orders/domain/repositories/order_repository.dart';

class SearchOrdersUseCase implements UseCase<List<OrderEntity>, String> {
  final OrderRepository _repo;
  const SearchOrdersUseCase(this._repo);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(
    String query,
  ) =>
      _repo.searchOrders(query);
}
