// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering, sort_constructors_first, avoid_positional_boolean_parameters

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/usecases/usecase.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';
import 'package:style_cart/features/products/domain/repositories/product_repository.dart';

class CreateProductParams extends Equatable {
  final ProductEntity product;
  final List<String> imageLocalPaths;
  const CreateProductParams({
    required this.product,
    required this.imageLocalPaths,
  });
  @override
  List<Object> get props => [product, imageLocalPaths];
}

class CreateProductUseCase
    implements UseCase<String, CreateProductParams> {
  final ProductRepository _repo;
  const CreateProductUseCase(this._repo);

  @override
  Future<Either<Failure, String>> call(
    CreateProductParams params,
  ) {
    // Validate product data
    if (params.product.name.trim().length < 3) {
      return Future.value(
        const Left(ValidationFailure(
          'Product name must be at least 3 characters',
        )),
      );
    }
    if (params.product.price <= 0) {
      return Future.value(
        const Left(ValidationFailure('Price must be > 0')),
      );
    }
    if (params.imageLocalPaths.isEmpty) {
      return Future.value(
        const Left(ValidationFailure(
          'At least 1 product image is required',
        )),
      );
    }
    if (params.product.discountPct < 0 ||
        params.product.discountPct > 90) {
      return Future.value(
        const Left(ValidationFailure(
          'Discount must be between 0% and 90%',
        )),
      );
    }
    return _repo.createProduct(
      params.product,
      params.imageLocalPaths,
    );
  }
}

