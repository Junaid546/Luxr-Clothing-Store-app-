// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering, sort_constructors_first, avoid_positional_boolean_parameters

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/usecases/usecase.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';
import 'package:style_cart/features/products/domain/repositories/product_repository.dart';

class UpdateProductParams extends Equatable {
  final ProductEntity product;
  final List<String> newImageLocalPaths;
  final List<String> removedImageUrls;
  const UpdateProductParams({
    required this.product,
    this.newImageLocalPaths = const [],
    this.removedImageUrls = const [],
  });
  @override
  List<Object> get props => [product];
}

class UpdateProductUseCase
    implements UseCase<void, UpdateProductParams> {
  final ProductRepository _repo;
  const UpdateProductUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(
    UpdateProductParams params,
  ) {
    if (params.product.productId.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Invalid product')),
      );
    }
    return _repo.updateProduct(
      params.product,
      params.newImageLocalPaths,
      params.removedImageUrls,
    );
  }
}

