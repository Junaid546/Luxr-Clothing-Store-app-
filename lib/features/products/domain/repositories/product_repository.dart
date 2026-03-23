// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering, sort_constructors_first, avoid_positional_boolean_parameters

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';
import 'package:style_cart/features/products/domain/entities/product_filter_entity.dart';

abstract interface class ProductRepository {

  // â”€â”€ Customer operations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<Either<Failure, List<ProductEntity>>> getProducts({
    required ProductFilter filter,
    Object? lastDocumentSnapshot, // cursor for pagination
  });

  Future<Either<Failure, ProductEntity>> getProductById(
    String productId,
  );

  Future<Either<Failure, List<ProductEntity>>> searchProducts(
    String query,
  );

  Future<Either<Failure, List<ProductEntity>>> getProductsByIds(
    List<String> productIds,
  );

  Stream<Either<Failure, ProductEntity>> watchProduct(
    String productId,
  );

  // â”€â”€ Admin operations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<Either<Failure, String>> createProduct(
    ProductEntity product,
    List<String> imageLocalPaths, // local file paths
  );

  Future<Either<Failure, void>> updateProduct(
    ProductEntity product,
    List<String> newImageLocalPaths, // new images to upload
    List<String> removedImageUrls,   // old URLs to delete
  );

  Future<Either<Failure, void>> toggleProductStatus(
    String productId,
    bool isActive,
  );

  Future<Either<Failure, void>> updateInventory({
    required String productId,
    required Map<String, int> inventory,
  });

  Future<Either<Failure, List<ProductEntity>>> getLowStockProducts(
    int threshold,
  );

  // â”€â”€ Atomic stock operations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<Either<Failure, void>> reserveStock({
    required String productId,
    required String size,
    required int quantity,
  });

  Future<Either<Failure, void>> releaseStock({
    required String productId,
    required String size,
    required int quantity,
  });

  // Batch version for order placement
  Future<Either<Failure, void>> reserveMultipleItems(
    List<StockReservationItem> items,
  );

  Future<Either<Failure, void>> releaseMultipleItems(
    List<StockReservationItem> items,
  );
}

// Reserve/release request model
class StockReservationItem extends Equatable {
  final String productId;
  final String productName; // for error messages
  final String size;
  final int quantity;

  const StockReservationItem({
    required this.productId,
    required this.productName,
    required this.size,
    required this.quantity,
  });

  @override
  List<Object> get props => [productId, size, quantity];
}

