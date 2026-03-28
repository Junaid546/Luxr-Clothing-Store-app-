// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering, sort_constructors_first, avoid_positional_boolean_parameters

import 'package:dartz/dartz.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/core/usecases/usecase.dart';
import 'package:stylecart/features/products/domain/entities/product_entity.dart';
import 'package:stylecart/features/products/domain/repositories/product_repository.dart';

class SearchProductsUseCase implements UseCase<List<ProductEntity>, String> {
  final ProductRepository _repo;
  const SearchProductsUseCase(this._repo);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(
    String query,
  ) {
    if (query.trim().length < 2) {
      return Future.value(const Right([]));
    }
    return _repo.searchProducts(query.trim().toLowerCase());
  }
}
