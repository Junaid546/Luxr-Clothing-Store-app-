// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/products/data/models/product_model.dart';

abstract interface class ProductRepository {
  // Paginated product listing with filters
  Future<Either<Failure, List<ProductModel>>> getProducts({
    String? category,
    String? sortBy,      // 'newest'|'price_asc'|'price_desc'|'rating'|'popular'
    bool? isFeatured,
    bool? isNewArrival,
    int limit = 20,
    DocumentSnapshot? lastDocument,  // for pagination
  });

  Future<Either<Failure, ProductModel>> getProductById(
    String productId);

  Future<Either<Failure, List<ProductModel>>> searchProducts(
    String query);

  Future<Either<Failure, List<ProductModel>>> getProductsByIds(
    List<String> ids);

  // Admin only
  Future<Either<Failure, String>> createProduct(
    ProductModel product);
  
  Future<Either<Failure, void>> updateProduct(
    ProductModel product);
  
  Future<Either<Failure, void>> deleteProduct(
    String productId);  // soft delete: isActive = false

  // Atomic stock operations (CRITICAL)
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

  // Batch stock update for multiple items
  Future<Either<Failure, void>> reserveMultipleItems(
    List<({String productId, String size, int quantity})> items,
  );

  // Stream for real-time product updates
  Stream<Either<Failure, ProductModel>> watchProduct(
    String productId);
}

