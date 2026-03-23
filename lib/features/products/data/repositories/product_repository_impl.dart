// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/data/firestore_base_repository.dart';
import 'package:style_cart/core/errors/exceptions.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/products/data/models/product_model.dart';
import 'package:style_cart/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl 
    extends FirestoreBaseRepository
    implements ProductRepository {

  ProductRepositoryImpl(super.firestore);

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      firestore.collection(FirestoreConstants.products);

  // â”€â”€ Get Products (paginated + filtered) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Future<Either<Failure, List<ProductModel>>> getProducts({
    String? category,
    String? sortBy,
    bool? isFeatured,
    bool? isNewArrival,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) {
    return safeFirestoreCall(() async {
      Query<Map<String, dynamic>> query = _productsRef
          .where('isActive', isEqualTo: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      if (isFeatured == true) {
        query = query.where('isFeatured', isEqualTo: true);
      }
      if (isNewArrival == true) {
        query = query.where('isNewArrival', isEqualTo: true);
      }

      // Apply sort
      query = switch (sortBy) {
        'price_asc'  => query.orderBy('finalPrice', descending: false),
        'price_desc' => query.orderBy('finalPrice', descending: true),
        'rating'     => query.orderBy('avgRating', descending: true),
        'popular'    => query.orderBy('soldCount', descending: true),
        _            => query.orderBy('createdAt', descending: true), // newest default
      };

      // Pagination cursor
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map(ProductModel.fromFirestore).toList();
    });
  }

  // â”€â”€ Get Single Product â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Future<Either<Failure, ProductModel>> getProductById(String productId) {
    return safeFirestoreCall(() async {
      final doc = await _productsRef.doc(productId).get();
      if (!doc.exists) {
        throw const NotFoundException('Product not found');
      }
      // Increment viewCount (non-blocking, best effort)
      unawaited(_productsRef.doc(productId).update({
        'viewCount': FieldValue.increment(1),
      }).catchError((_) {})); // ignore errors for non-blocking update
      return ProductModel.fromFirestore(doc);
    });
  }

  // â”€â”€ Search Products â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Future<Either<Failure, List<ProductModel>>> searchProducts(String query) {
    return safeFirestoreCall(() async {
      if (query.trim().isEmpty) return [];
      
      final searchTerm = query.toLowerCase().trim();
      final snapshot = await _productsRef
          .where('isActive', isEqualTo: true)
          .where('searchIndex', arrayContains: searchTerm)
          .limit(30)
          .get();
      return snapshot.docs.map(ProductModel.fromFirestore).toList();
    });
  }

  // â”€â”€ Get Products By IDs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Future<Either<Failure, List<ProductModel>>> getProductsByIds(List<String> ids) {
    return safeFirestoreCall(() async {
      if (ids.isEmpty) return [];
      final uniqueIds = ids.toSet().toList();
      final chunks = <List<String>>[];
      for (var i = 0; i < uniqueIds.length; i += 10) {
        chunks.add(uniqueIds.sublist(i, i + 10 > uniqueIds.length ? uniqueIds.length : i + 10));
      }
      final results = <ProductModel>[];
      for (final chunk in chunks) {
        final snap = await _productsRef.where(FieldPath.documentId, whereIn: chunk).get();
        results.addAll(snap.docs.map(ProductModel.fromFirestore));
      }
      return results;
    });
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // ATOMIC STOCK RESERVATION
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  @override
  Future<Either<Failure, void>> reserveStock({
    required String productId,
    required String size,
    required int quantity,
  }) {
    return safeFirestoreCall(() async {
      final productRef = _productsRef.doc(productId);

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(productRef);

        if (!snapshot.exists) {
          throw const NotFoundException('Product not found');
        }

        final data = snapshot.data()!;
        final inventory = Map<String, dynamic>.from(
          data['inventory'] as Map? ?? {},
        );

        final currentStock = (inventory[size] as num?)?.toInt() ?? 0;

        if (currentStock < quantity) {
          throw StockException(
            currentStock == 0
                ? 'Size $size is out of stock'
                : 'Only $currentStock left in size $size',
          );
        }

        final newSizeStock = currentStock - quantity;
        final currentTotal = (data['totalStock'] as num?)?.toInt() ?? 0;
        final newTotal = currentTotal - quantity;

        transaction.update(productRef, {
          'inventory.$size': newSizeStock,
          'totalStock': newTotal,
          'soldCount': FieldValue.increment(quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    });
  }

  @override
  Future<Either<Failure, void>> releaseStock({
    required String productId,
    required String size,
    required int quantity,
  }) {
    return safeFirestoreCall(() async {
      await _productsRef.doc(productId).update({
        'inventory.$size': FieldValue.increment(quantity),
        'totalStock': FieldValue.increment(quantity),
        'soldCount': FieldValue.increment(-quantity),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Stream<Either<Failure, ProductModel>> watchProduct(String productId) {
    return safeFirestoreStream(() =>
      _productsRef.doc(productId).snapshots()
          .where((doc) => doc.exists)
          .map(ProductModel.fromFirestore),
    );
  }

  // â”€â”€ Admin operations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Future<Either<Failure, String>> createProduct(ProductModel product) {
    return safeFirestoreCall(() async {
      final docRef = _productsRef.doc();
      final data = product.toFirestore();
      data['productId'] = docRef.id;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['viewCount'] = 0;
      data['soldCount'] = 0;
      data['avgRating'] = 0.0;
      data['reviewCount'] = 0;
      await docRef.set(data);
      return docRef.id;
    });
  }

  @override
  Future<Either<Failure, void>> updateProduct(ProductModel product) {
    return safeFirestoreCall(() async {
      await _productsRef.doc(product.productId).update(product.toFirestore());
    });
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) {
    return safeFirestoreCall(() async {
      await _productsRef.doc(productId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // â”€â”€ Batch stock update for multiple items â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Future<Either<Failure, void>> reserveMultipleItems(
    List<({String productId, String size, int quantity})> items,
  ) {
    return safeFirestoreCall(() async {
      await firestore.runTransaction((transaction) async {
        // READ all products first
        final snapshots = await Future.wait(
          items.map((item) => transaction.get(_productsRef.doc(item.productId))),
        );

        // VALIDATE all stocks before any write
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          final data = snapshots[i].data()!;
          final inventory = Map<String, dynamic>.from(
            data['inventory'] as Map? ?? {},
          );
          final stock = (inventory[item.size] as num?)?.toInt() ?? 0;
          if (stock < item.quantity) {
            final name = data['name'] as String? ?? '';
            throw StockException(
              stock == 0
                ? '$name (Size ${item.size}) is out of stock'
                : '$name: Only $stock left in size ${item.size}',
            );
          }
        }

        // ALL valid â€” now WRITE all updates
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          final data = snapshots[i].data()!;
          final inventory = Map<String, dynamic>.from(
            data['inventory'] as Map? ?? {},
          );
          final currentStock = (inventory[item.size] as num?)?.toInt() ?? 0;
          final currentTotal = (data['totalStock'] as num?)?.toInt() ?? 0;

          transaction.update(
            _productsRef.doc(item.productId),
            {
              'inventory.${item.size}': currentStock - item.quantity,
              'totalStock': currentTotal - item.quantity,
              'soldCount': FieldValue.increment(item.quantity),
              'updatedAt': FieldValue.serverTimestamp(),
            },
          );
        }
      });
    });
  }
}

