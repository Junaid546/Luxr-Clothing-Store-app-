// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering, sort_constructors_first, avoid_positional_boolean_parameters

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/core/usecases/usecase.dart';
import 'package:stylecart/features/products/domain/repositories/product_repository.dart';

class UpdateInventoryParams extends Equatable {
  final String productId;
  final Map<String, int> inventory;
  const UpdateInventoryParams({
    required this.productId,
    required this.inventory,
  });
  @override
  List<Object> get props => [productId, inventory];
}

class UpdateInventoryUseCase implements UseCase<void, UpdateInventoryParams> {
  final ProductRepository _repo;
  const UpdateInventoryUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(
    UpdateInventoryParams params,
  ) {
    // Validate: no negative stock values
    for (final entry in params.inventory.entries) {
      if (entry.value < 0) {
        return Future.value(
          Left(ValidationFailure(
            'Stock for size ${entry.key} cannot be negative',
          )),
        );
      }
    }
    return _repo.updateInventory(
      productId: params.productId,
      inventory: params.inventory,
    );
  }
}
