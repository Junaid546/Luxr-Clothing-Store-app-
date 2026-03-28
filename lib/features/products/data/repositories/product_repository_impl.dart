// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering, sort_constructors_first, avoid_positional_boolean_parameters

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:stylecart/core/constants/firestore_constants.dart';
import 'package:stylecart/core/data/firestore_base_repository.dart';
import 'package:stylecart/core/errors/exceptions.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/features/products/data/models/product_model.dart';
import 'package:stylecart/features/products/domain/entities/product_entity.dart';
import 'package:stylecart/features/products/domain/entities/product_filter_entity.dart';
import 'package:stylecart/features/products/domain/repositories/image_repository.dart';
import 'package:stylecart/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl extends FirestoreBaseRepository
    implements ProductRepository {
  final ImageRepository _imageRepo;

  ProductRepositoryImpl(
    super.firestore,
    this._imageRepo,
  );

  CollectionReference<Map<String, dynamic>> get _ref =>
      firestore.collection(FirestoreConstants.products);

  // ══════════════════════════════════════════════════
  // GET PRODUCTS — Paginated + Filtered
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    required ProductFilter filter,
    Object? lastDocumentSnapshot,
  }) {
    return safeFirestoreCall(() async {
      Query<Map<String, dynamic>> query = _ref;

      // ── Apply filters ─────────────────────────────
      if (filter.category != null) {
        query = query.where(
          'category',
          isEqualTo: filter.category,
        );
      }
      if (filter.isFeatured == true) {
        query = query.where('isFeatured', isEqualTo: true);
      }
      if (filter.isNewArrival == true) {
        query = query.where('isNewArrival', isEqualTo: true);
      }
      if (filter.isLimitedEdition == true) {
        query = query.where(
          'isLimitedEdition',
          isEqualTo: true,
        );
      }

      // ── Apply sort ────────────────────────────────
      // IMPORTANT: sort field must match Firestore index
      query = switch (filter.sortBy) {
        'price_asc' => query.orderBy('finalPrice'),
        'price_desc' => query.orderBy('finalPrice', descending: true),
        'rating' => query.orderBy('avgRating', descending: true),
        'popular' => query.orderBy('soldCount', descending: true),
        _ => query.orderBy('createdAt', descending: true),
      };

      // ── Pagination cursor ─────────────────────────
      if (lastDocumentSnapshot != null) {
        query = query.startAfterDocument(
          lastDocumentSnapshot as DocumentSnapshot,
        );
      }

      query = query.limit(filter.pageSize);
      final snapshot = await query.get();

      var products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc).toEntity())
          .where((p) => p.isActive)
          .toList();

      // ── Client-side price range filter ───────────
      // Firestore can't do range + orderBy on different fields
      // So we filter price range client-side
      if (filter.minPrice != null) {
        products =
            products.where((p) => p.finalPrice >= filter.minPrice!).toList();
      }
      if (filter.maxPrice != null) {
        products =
            products.where((p) => p.finalPrice <= filter.maxPrice!).toList();
      }

      // ── Client-side size filter ───────────────────
      if (filter.sizes.isNotEmpty) {
        products = products
            .where(
              (p) => filter.sizes.any((size) => p.isSizeAvailable(size)),
            )
            .toList();
      }

      return products;
    });
  }

  // ══════════════════════════════════════════════════
  // GET SINGLE PRODUCT
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, ProductEntity>> getProductById(
    String productId,
  ) {
    return safeFirestoreCall(() async {
      final doc = await _ref.doc(productId).get();
      if (!doc.exists) {
        throw const NotFoundException('Product not found');
      }
      // Increment view count (fire and forget)
      unawaited(_ref.doc(productId).update({
        'viewCount': FieldValue.increment(1),
      }).catchError((_) {}));
      return ProductModel.fromFirestore(doc).toEntity();
    });
  }

  // ══════════════════════════════════════════════════
  // SEARCH PRODUCTS
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
    String query,
  ) {
    return safeFirestoreCall(() async {
      // Tokenize the query for better matching
      final tokens =
          query.toLowerCase().split(' ').where((t) => t.length >= 2).toList();

      if (tokens.isEmpty) return [];

      // Search by first token (Firestore limitation:
      // arrayContains takes 1 value, not array)
      final snapshot = await _ref
          .where('searchIndex', arrayContains: tokens.first)
          .limit(50)
          .get();

      var results = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc).toEntity())
          .where((p) => p.isActive)
          .toList();

      // Client-side filter for remaining tokens
      // if (tokens.length > 1) {
      //   results = results.where((product) {
      //     return tokens.skip(1).every((token) =>
      //       product.searchIndex.any( // Wait, entity doesn't have searchIndex.
      //         (idx) => idx.contains(token),
      //       ),
      //     );
      //   }).toList();
      // }
      // To properly filter we need to tokenize the entity properties or map afterwards.
      // Since entity properties include name, brand, tags, we can just check those.
      if (tokens.length > 1) {
        results = results.where((product) {
          final searchableText =
              '${product.name} ${product.brand} ${product.tags.join(' ')}'
                  .toLowerCase();
          return tokens
              .skip(1)
              .every((token) => searchableText.contains(token));
        }).toList();
      }

      return results;
    });
  }

  // ══════════════════════════════════════════════════
  // GET PRODUCTS BY IDS (for wishlist/cart refresh)
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByIds(
    List<String> productIds,
  ) {
    return safeFirestoreCall(() async {
      if (productIds.isEmpty) return [];

      // Firestore whereIn limit = 30
      final chunks = <List<String>>[];
      for (int i = 0; i < productIds.length; i += 30) {
        chunks.add(productIds.sublist(
          i,
          (i + 30 > productIds.length) ? productIds.length : i + 30,
        ));
      }

      final results = <ProductEntity>[];
      for (final chunk in chunks) {
        final snapshot =
            await _ref.where(FieldPath.documentId, whereIn: chunk).get();
        results.addAll(
          snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc).toEntity()),
        );
      }
      return results;
    });
  }

  // ══════════════════════════════════════════════════
  // REAL-TIME WATCH
  // ══════════════════════════════════════════════════
  @override
  Stream<Either<Failure, ProductEntity>> watchProduct(
    String productId,
  ) {
    return _ref
        .doc(productId)
        .snapshots()
        .map<Either<Failure, ProductEntity>>((doc) {
      if (!doc.exists) {
        return Left<Failure, ProductEntity>(
          NotFoundFailure('Product with ID $productId not found'),
        );
      }
      try {
        return Right<Failure, ProductEntity>(
          ProductModel.fromFirestore(doc).toEntity(),
        );
      } catch (e) {
        return Left<Failure, ProductEntity>(
          ServerFailure('Failed to parse product: $e'),
        );
      }
    }).handleError((Object error) {
      return Left<Failure, ProductEntity>(ServerFailure(error.toString()));
    });
  }

  // ══════════════════════════════════════════════════
  // CREATE PRODUCT (Admin)
  // Uploads images → writes Firestore doc atomically
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, String>> createProduct(
    ProductEntity product,
    List<String> imageLocalPaths,
  ) async {
    // 1. Generate Firestore doc ref FIRST to get the ID
    final docRef = _ref.doc();
    final productId = docRef.id;

    // 2. Upload images to Storage using the productId
    final uploadResult = await _imageRepo.uploadProductImages(
      localPaths: imageLocalPaths,
      productId: productId,
    );

    // If upload fails → return failure (no Firestore doc created)
    if (uploadResult.isLeft()) {
      return Left(uploadResult.fold((f) => f, (_) => const ServerFailure()));
    }

    final imageUrls = uploadResult.getOrElse(() => []);

    // 3. Build Firestore document
    return safeFirestoreCall(() async {
      final searchTerms = <String>{};
      for (final word in [
        product.name,
        product.brand,
        product.category,
        ...product.tags,
      ]) {
        searchTerms.addAll(
          word.toLowerCase().split(' '),
        );
      }

      final computedTotal = product.inventory.values.fold(0, (a, b) => a + b);

      final data = <String, dynamic>{
        'productId': productId,
        'name': product.name,
        'brand': product.brand,
        'description': product.description,
        'category': product.category,
        'subcategory': product.subcategory,
        'tags': product.tags,
        'searchIndex': searchTerms.toList(),
        'price': product.price,
        'discountPct': product.discountPct,
        'finalPrice': product.price * (1 - product.discountPct / 100),
        'imageUrls': imageUrls,
        'thumbnailUrl': imageUrls.isNotEmpty ? imageUrls.first : '',
        'inventory': product.inventory,
        'totalStock': computedTotal,
        'lowStockThreshold': product.lowStockThreshold,
        'colors': product.colors
            .map((c) => {
                  'name': c.name,
                  'hexCode': c.hexCode,
                })
            .toList(),
        'isActive': true,
        'isFeatured': product.isFeatured,
        'isNewArrival': product.isNewArrival,
        'isLimitedEdition': product.isLimitedEdition,
        'avgRating': 0.0,
        'reviewCount': 0,
        'soldCount': 0,
        'viewCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': product.createdBy,
      };

      await docRef.set(data);
      return productId;
    });
  }

  // ══════════════════════════════════════════════════
  // UPDATE PRODUCT (Admin)
  // Uploads new images → deletes removed ones → updates doc
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> updateProduct(
    ProductEntity product,
    List<String> newImageLocalPaths,
    List<String> removedImageUrls,
  ) async {
    // 1. Upload new images if any
    var imageUrls = List<String>.from(product.imageUrls);

    if (newImageLocalPaths.isNotEmpty) {
      final uploadResult = await _imageRepo.uploadProductImages(
        localPaths: newImageLocalPaths,
        productId: product.productId,
      );
      if (uploadResult.isLeft()) {
        return Left(uploadResult.fold(
          (f) => f,
          (_) => const ServerFailure(),
        ));
      }
      imageUrls.addAll(uploadResult.getOrElse(() => []));
    }

    // 2. Remove deleted image URLs from list
    if (removedImageUrls.isNotEmpty) {
      imageUrls.removeWhere(
        (url) => removedImageUrls.contains(url),
      );
      // Delete from Storage (best effort, non-blocking)
      unawaited(_imageRepo
          .deleteImages(removedImageUrls)
          .catchError((_) => const Right<Failure, void>(null)));
    }

    if (imageUrls.isEmpty) {
      return const Left(
        ValidationFailure('Product must have at least 1 image'),
      );
    }

    // 3. Update Firestore
    return safeFirestoreCall(() async {
      final searchTerms = <String>{};
      for (final word in [
        product.name,
        product.brand,
        product.category,
        ...product.tags,
      ]) {
        searchTerms.addAll(word.toLowerCase().split(' '));
      }

      final computedTotal = product.inventory.values.fold(0, (a, b) => a + b);

      await _ref.doc(product.productId).update({
        'name': product.name,
        'brand': product.brand,
        'description': product.description,
        'category': product.category,
        'subcategory': product.subcategory,
        'tags': product.tags,
        'searchIndex': searchTerms.toList(),
        'price': product.price,
        'discountPct': product.discountPct,
        'finalPrice': product.price * (1 - product.discountPct / 100),
        'imageUrls': imageUrls,
        'thumbnailUrl': imageUrls.isNotEmpty ? imageUrls.first : '',
        'inventory': product.inventory,
        'totalStock': computedTotal,
        'lowStockThreshold': product.lowStockThreshold,
        'colors': product.colors
            .map((c) => {
                  'name': c.name,
                  'hexCode': c.hexCode,
                })
            .toList(),
        'isFeatured': product.isFeatured,
        'isNewArrival': product.isNewArrival,
        'isLimitedEdition': product.isLimitedEdition,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ══════════════════════════════════════════════════
  // TOGGLE STATUS (Admin soft delete)
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> toggleProductStatus(
    String productId,
    bool isActive,
  ) {
    return safeFirestoreCall(() async {
      await _ref.doc(productId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ══════════════════════════════════════════════════
  // UPDATE INVENTORY (Admin)
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> updateInventory({
    required String productId,
    required Map<String, int> inventory,
  }) {
    return safeFirestoreCall(() async {
      final total = inventory.values.fold(0, (a, b) => a + b);
      await _ref.doc(productId).update({
        'inventory': inventory,
        'totalStock': total,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ══════════════════════════════════════════════════
  // GET LOW STOCK PRODUCTS (Admin alert)
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, List<ProductEntity>>> getLowStockProducts(
    int threshold,
  ) {
    return safeFirestoreCall(() async {
      final snapshot = await _ref
          .where('totalStock', isLessThanOrEqualTo: threshold)
          .orderBy('totalStock')
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc).toEntity())
          .where((p) => p.isActive)
          .toList();
    });
  }

  // ══════════════════════════════════════════════════
  // ATOMIC STOCK RESERVATION (Single item)
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> reserveStock({
    required String productId,
    required String size,
    required int quantity,
  }) {
    return safeFirestoreCall(() async {
      await firestore.runTransaction((txn) async {
        final ref = _ref.doc(productId);
        final snap = await txn.get(ref);

        if (!snap.exists) {
          throw const NotFoundException('Product not found');
        }

        final data = snap.data()!;
        final inv = Map<String, dynamic>.from(
          data['inventory'] as Map? ?? {},
        );
        final current = (inv[size] as num?)?.toInt() ?? 0;

        if (current < quantity) {
          throw StockException(
            current == 0
                ? 'Size $size is out of stock'
                : 'Only $current units left in size $size',
          );
        }

        final newSizeQty = current - quantity;
        final currentTotal = (data['totalStock'] as num?)?.toInt() ?? 0;

        // Compute new total manually (no FieldValue inside txn)
        final newTotal = currentTotal - quantity;

        txn.update(ref, {
          'inventory.$size': newSizeQty,
          'totalStock': newTotal,
          'soldCount': (data['soldCount'] as num? ?? 0) + quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    });
  }

  // ══════════════════════════════════════════════════
  // ATOMIC STOCK RELEASE (cancel/return)
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> releaseStock({
    required String productId,
    required String size,
    required int quantity,
  }) {
    return safeFirestoreCall(() async {
      // Release doesn't need a transaction —
      // increment is safe here because we're adding stock back
      // and there's no "stock cannot exceed max" constraint
      await _ref.doc(productId).update({
        'inventory.$size': FieldValue.increment(quantity),
        'totalStock': FieldValue.increment(quantity),
        'soldCount': FieldValue.increment(-quantity),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ══════════════════════════════════════════════════
  // BATCH STOCK RESERVATION (Order placement)
  // READ ALL → VALIDATE ALL → WRITE ALL
  // This is the most critical operation in the app
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> reserveMultipleItems(
    List<StockReservationItem> items,
  ) {
    return safeFirestoreCall(() async {
      await firestore.runTransaction((txn) async {
        // ── PHASE 1: READ ALL ─────────────────────
        final refs = items.map((item) => _ref.doc(item.productId)).toList();

        final snapshots = await Future.wait(
          refs.map((ref) => txn.get(ref)),
        );

        // ── PHASE 2: VALIDATE ALL ─────────────────
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          final snap = snapshots[i];

          if (!snap.exists) {
            throw NotFoundException(
              '${item.productName} no longer exists',
            );
          }

          final data = snap.data()!;
          if (data['isActive'] == false) {
            throw ValidationException(
              '${item.productName} is no longer available',
            );
          }

          final inv = Map<String, dynamic>.from(
            data['inventory'] as Map? ?? {},
          );
          final stock = (inv[item.size] as num?)?.toInt() ?? 0;

          if (stock < item.quantity) {
            throw StockException(
              stock == 0
                  ? '${item.productName} (Size ${item.size})'
                      ' is out of stock'
                  : '${item.productName}: Only $stock left'
                      ' in size ${item.size}',
            );
          }
        }

        // ── PHASE 3: WRITE ALL ────────────────────
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          final data = snapshots[i].data()!;
          final inv = Map<String, dynamic>.from(
            data['inventory'] as Map? ?? {},
          );
          final current = (inv[item.size] as num?)?.toInt() ?? 0;
          final total = (data['totalStock'] as num?)?.toInt() ?? 0;
          final sold = (data['soldCount'] as num?)?.toInt() ?? 0;

          txn.update(refs[i], {
            'inventory.${item.size}': current - item.quantity,
            'totalStock': total - item.quantity,
            'soldCount': sold + item.quantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    });
  }

  // ── Release multiple (order cancel) ───────────────
  @override
  Future<Either<Failure, void>> releaseMultipleItems(
    List<StockReservationItem> items,
  ) async {
    return safeFirestoreCall(() async {
      final batch = firestore.batch();
      for (final item in items) {
        batch.update(_ref.doc(item.productId), {
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
