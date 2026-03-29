import 'package:dartz/dartz.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/usecases/usecase.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';
import 'package:style_cart/features/orders/domain/repositories/order_repository.dart';

class SearchOrdersUseCase implements UseCase<List<OrderEntity>, String> {
  const SearchOrdersUseCase(this._repo);
  final OrderRepository _repo;

  @override
  Future<Either<Failure, List<OrderEntity>>> call(String query) =>
      _repo.searchOrders(query);
}
