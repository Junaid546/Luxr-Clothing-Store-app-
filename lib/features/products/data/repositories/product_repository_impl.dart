// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering, sort_constructors_first, avoid_positional_boolean_parameters

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/data/firestore_base_repository.dart';
import 'package:style_cart/core/errors/exceptions.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/products/data/models/product_model.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';
import 'package:style_cart/features/products/domain/entities/product_filter_entity.dart';
import 'package:style_cart/features/products/domain/repositories/product_repository.dart';

extension ProductModelMapper on ProductModel {
  ProductEntity toEntity() {
    return ProductEntity(
      productId: productId,
      name: name,
      brand: brand,
      description: description,
      category: category,
      subcategory: subcategory,
      tags: tags,
      price: price,
      discountPct: discountPct,
      finalPrice: finalPrice,
      imageUrls: imageUrls,
      thumbnailUrl: thumbnailUrl,
      inventory: inventory,
      totalStock: totalStock,
      lowStockThreshold: lowStockThreshold,
      colors: colors.map((c) => ProductColorEntity(name: c.name, hexCode: c.hexCode)).toList(),
      isActive: isActive,
      isFeatured: isFeatured,
      isNewArrival: isNewArrival,
      isLimitedEdition: isLimitedEdition,
      avgRating: avgRating,
      reviewCount: reviewCount,
      soldCount: soldCount,
      viewCount: viewCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
    );
  }
}

extension ProductEntityMapper on ProductEntity {
  ProductModel toModel() {
    return ProductModel(
      productId: productId,
      name: name,
      brand: brand,
      description: description,
      category: category,
      subcategory: subcategory,
      tags: tags,
      searchIndex: const [], // will be set correctly by toFirestore
      price: price,
      discountPct: discountPct,
      finalPrice: finalPrice,
      imageUrls: imageUrls,
      thumbnailUrl: thumbnailUrl,
      inventory: inventory,
      totalStock: totalStock,
      lowStockThreshold: lowStockThreshold,
      colors: colors.map((c) => ProductColor(name: c.name, hexCode: c.hexCode)).toList(),
      isActive: isActive,
      isFeatured: isFeatured,
      isNewArrival: isNewArrival,
      isLimitedEdition: isLimitedEdition,
      avgRating: avgRating,
      reviewCount: reviewCount,
      soldCount: soldCount,
      viewCount: viewCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
    );
  }
}

class ProductRepositoryImpl extends FirestoreBaseRepository implements ProductRepository {
  ProductRepositoryImpl(super.firestore);

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      firestore.collection(FirestoreConstants.products);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    required ProductFilter filter,
    Object? lastDocumentSnapshot,
  }) {
    return safeFirestoreCall(() async {
      Query<Map<String, dynamic>> query = _productsRef.where('isActive', isEqualTo: true);

      if (filter.category != null && filter.category!.isNotEmpty) {
        query = query.where('category', isEqualTo: filter.category);
      }
      if (filter.isFeatured == true) {
        query = query.where('isFeatured', isEqualTo: true);
      }
      if (filter.isNewArrival == true) {
        query = query.where('isNewArrival', isEqualTo: true);
      }
      if (filter.isLimitedEdition == true) {
        query = query.where('isLimitedEdition', isEqualTo: true);
      }

      // We handle minPrice and maxPrice in Dart because Firestore allows range filters on only ONE field.
      // Apply sort
      query = switch (filter.sortBy) {
        'price_asc'  => query.orderBy('finalPrice', descending: false),
        'price_desc' => query.orderBy('finalPrice', descending: true),
        'rating'     => query.orderBy('avgRating', descending: true),
        'popular'    => query.orderBy('soldCount', descending: true),
        _            => query.orderBy('createdAt', descending: true),
      };

      if (lastDocumentSnapshot != null && lastDocumentSnapshot is DocumentSnapshot) {
        query = query.startAfterDocument(lastDocumentSnapshot);
      }

      query = query.limit(filter.pageSize * 2); // Overfetch to allow client-side filtering of prices and sizes

      final snapshot = await query.get();
      var products = snapshot.docs.map((doc) => ProductModel.fromFirestore(doc).toEntity()).toList();

      if (filter.minPrice != null) {
        products = products.where((p) => p.finalPrice >= filter.minPrice!).toList();
      }
      if (filter.maxPrice != null) {
        products = products.where((p) => p.finalPrice <= filter.maxPrice!).toList();
      }
      if (filter.sizes.isNotEmpty) {
        products = products.where((p) => filter.sizes.any((s) => p.isSizeAvailable(s))).toList();
      }

      return products.take(filter.pageSize).toList();
    });
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String productId) {
    return safeFirestoreCall(() async {
      final doc = await _productsRef.doc(productId).get();
      if (!doc.exists) {
        throw const NotFoundException('Product not found');
      }
      return ProductModel.fromFirestore(doc).toEntity();
    });
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query) {
    return safeFirestoreCall(() async {
      if (query.trim().isEmpty) return [];
      
      final searchTerm = query.toLowerCase().trim();
      final snapshot = await _productsRef
          .where('isActive', isEqualTo: true)
          .where('searchIndex', arrayContains: searchTerm)
          .limit(30)
          .get();
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc).toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByIds(List<String> productIds) {
    return safeFirestoreCall(() async {
      if (productIds.isEmpty) return [];
      final uniqueIds = productIds.toSet().toList();
      final chunks = <List<String>>[];
      for (var i = 0; i < uniqueIds.length; i += 10) {
        chunks.add(uniqueIds.sublist(i, i + 10 > uniqueIds.length ? uniqueIds.length : i + 10));
      }
      final results = <ProductEntity>[];
      for (final chunk in chunks) {
        final snap = await _productsRef.where(FieldPath.documentId, whereIn: chunk).get();
        results.addAll(snap.docs.map((doc) => ProductModel.fromFirestore(doc).toEntity()));
      }
      return results;
    });
  }

  @override
  Stream<Either<Failure, ProductEntity>> watchProduct(String productId) {
    return safeFirestoreStream(() =>
      _productsRef.doc(productId).snapshots()
          .where((doc) => doc.exists)
          .map((doc) => ProductModel.fromFirestore(doc).toEntity()),
    );
  }

  @override
  Future<Either<Failure, String>> createProduct(ProductEntity product, List<String> imageLocalPaths) {
    return safeFirestoreCall(() async {
      final docRef = _productsRef.doc();
      final data = product.toModel().toFirestore();
      data['productId'] = docRef.id;
      data['createdAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);
      return docRef.id;
    });
  }

  @override
  Future<Either<Failure, void>> updateProduct(ProductEntity product, List<String> newImageLocalPaths, List<String> removedImageUrls) {
    return safeFirestoreCall(() async {
      await _productsRef.doc(product.productId).update(product.toModel().toFirestore());
    });
  }

  @override
  Future<Either<Failure, void>> toggleProductStatus(String productId, bool isActive) {
    return safeFirestoreCall(() async {
      await _productsRef.doc(productId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<Either<Failure, void>> updateInventory({required String productId, required Map<String, int> inventory}) {
    return safeFirestoreCall(() async {
      final totalStock = inventory.values.fold(0, (a, b) => a + b);
      await _productsRef.doc(productId).update({
        'inventory': inventory,
        'totalStock': totalStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getLowStockProducts(int threshold) {
    return safeFirestoreCall(() async {
      final snap = await _productsRef
          .where('isActive', isEqualTo: true)
          .where('totalStock', isLessThanOrEqualTo: threshold)
          .orderBy('totalStock', descending: false)
          .limit(50)
          .get();
      return snap.docs.map((doc) => ProductModel.fromFirestore(doc).toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, void>> reserveStock({required String productId, required String size, required int quantity}) {
    return safeFirestoreCall(() async {
      final productRef = _productsRef.doc(productId);

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(productRef);

        if (!snapshot.exists) {
          throw const NotFoundException('Product not found');
        }

        final data = snapshot.data()!;
        final inventory = Map<String, dynamic>.from(data['inventory'] as Map? ?? {});
        final currentStock = (inventory[size] as num?)?.toInt() ?? 0;

        if (currentStock < quantity) {
          throw StockException(currentStock == 0 ? 'Size $size is out of stock' : 'Only $currentStock left in size $size');
        }

        transaction.update(productRef, {
          'inventory.$size': currentStock - quantity,
          'totalStock': ((data['totalStock'] as num?)?.toInt() ?? 0) - quantity,
          'soldCount': FieldValue.increment(quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    });
  }

  @override
  Future<Either<Failure, void>> releaseStock({required String productId, required String size, required int quantity}) {
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
  Future<Either<Failure, void>> reserveMultipleItems(List<StockReservationItem> items) {
    return safeFirestoreCall(() async {
      await firestore.runTransaction((transaction) async {
        final snapshots = await Future.wait(items.map((item) => transaction.get(_productsRef.doc(item.productId))));
        
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          final data = snapshots[i].data()!;
          final inventory = Map<String, dynamic>.from(data['inventory'] as Map? ?? {});
          final stock = (inventory[item.size] as num?)?.toInt() ?? 0;
          if (stock < item.quantity) {
            throw StockException(stock == 0 ? '${data['name']} (Size ${item.size}) is out of stock' : '${data['name']}: Only $stock left in size ${item.size}');
          }
        }

        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          final data = snapshots[i].data()!;
          final inventory = Map<String, dynamic>.from(data['inventory'] as Map? ?? {});
          final currentStock = (inventory[item.size] as num?)?.toInt() ?? 0;
          
          transaction.update(_productsRef.doc(item.productId), {
            'inventory.${item.size}': currentStock - item.quantity,
            'totalStock': ((data['totalStock'] as num?)?.toInt() ?? 0) - item.quantity,
            'soldCount': FieldValue.increment(item.quantity),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    });
  }

  @override
  Future<Either<Failure, void>> releaseMultipleItems(List<StockReservationItem> items) {
    return safeFirestoreCall(() async {
      final batch = firestore.batch();
      for (final item in items) {
        batch.update(_productsRef.doc(item.productId), {
          'inventory.${item.size}': FieldValue.increment(item.quantity),
          'totalStock': FieldValue.increment(item.quantity),
          'soldCount': FieldValue.increment(-item.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    });
  }
}

