import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/providers/repository_providers.dart';
import 'package:style_cart/features/products/data/models/product_model.dart';
import 'package:style_cart/features/products/data/providers/product_data_providers.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';
import 'package:style_cart/features/products/domain/entities/product_filter_entity.dart';

part 'paginated_product_notifier.freezed.dart';
part 'paginated_product_notifier.g.dart';

@freezed
class ProductPageState with _$ProductPageState {
  const factory ProductPageState({
    @Default([]) List<ProductEntity> products,
    @Default(true) bool hasMore,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasError,
    @Default('') String errorMessage,
    @Default(ProductFilter()) ProductFilter filter,
    // Store raw DocumentSnapshot for cursor
    Object? lastSnapshot,
    @Default(0) int totalLoaded,
  }) = _ProductPageState;
}

@riverpod
class PaginatedProductNotifier extends _$PaginatedProductNotifier {
  static const int _pageSize = 20;
  // Cache: productId → ProductEntity
  final _productCache = <String, ProductEntity>{};

  @override
  ProductPageState build() {
    return const ProductPageState();
  }

  // ── Initial load / filter change ──────────────────
  Future<void> loadProducts({
    ProductFilter? filter,
  }) async {
    final activeFilter = filter ?? state.filter;

    state = state.copyWith(
      isLoading: true,
      hasError: false,
      products: [],
      lastSnapshot: null,
      hasMore: true,
      totalLoaded: 0,
      filter: activeFilter,
    );

    await _fetchAndAppend(
      filter: activeFilter,
      lastSnapshot: null,
      isFirstPage: true,
    );
  }

  // ── Load more pages ────────────────────────────────
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    await _fetchAndAppend(
      filter: state.filter,
      lastSnapshot: state.lastSnapshot,
      isFirstPage: false,
    );
  }

  // ── Core fetch logic ───────────────────────────────
  Future<void> _fetchAndAppend({
    required ProductFilter filter,
    required Object? lastSnapshot,
    required bool isFirstPage,
  }) async {
    try {
      final firestore = ref.read(firestoreProvider);
      Query<Map<String, dynamic>> query = firestore
          .collection(FirestoreConstants.products)
          .where('isActive', isEqualTo: true);

      // Apply filters
      if (filter.category != null) {
        query = query.where(
          'category', isEqualTo: filter.category,
        );
      }
      if (filter.isFeatured == true) {
        query = query.where('isFeatured', isEqualTo: true);
      }
      if (filter.isNewArrival == true) {
        query = query.where(
          'isNewArrival', isEqualTo: true,
        );
      }

      // Apply sort (MUST match Firestore index)
      query = switch (filter.sortBy) {
        'price_asc'  => query.orderBy('finalPrice'),
        'price_desc' => query.orderBy(
                          'finalPrice', descending: true),
        'rating'     => query.orderBy(
                          'avgRating', descending: true),
        'popular'    => query.orderBy(
                          'soldCount', descending: true),
        _            => query.orderBy(
                          'createdAt', descending: true),
      };

      // Apply cursor
      if (lastSnapshot != null) {
        query = query.startAfterDocument(
          lastSnapshot as DocumentSnapshot,
        );
      }

      // Fetch page
      final snapshot = await query
          .limit(_pageSize)
          .get(const GetOptions(source: Source.serverAndCache));

      // Parse products
      var newProducts = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc).toEntity())
          .toList();

      // Client-side price range filter
      if (filter.minPrice != null) {
        newProducts = newProducts.where(
          (p) => p.finalPrice >= filter.minPrice!,
        ).toList();
      }
      if (filter.maxPrice != null) {
        newProducts = newProducts.where(
          (p) => p.finalPrice <= filter.maxPrice!,
        ).toList();
      }

      // Update memory cache
      for (final product in newProducts) {
        _productCache[product.productId] = product;
      }

      // Get cursor for next page
      final newLastSnapshot = snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : null;

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        products: isFirstPage
            ? newProducts
            : [...state.products, ...newProducts],
        hasMore: snapshot.docs.length >= _pageSize,
        lastSnapshot: newLastSnapshot,
        totalLoaded:
            (isFirstPage ? 0 : state.totalLoaded) + newProducts.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> applyFilter(ProductFilter filter) => loadProducts(filter: filter);

  Future<void> sortBy(String sortKey) =>
      loadProducts(filter: state.filter.copyWith(sortBy: sortKey));

  Future<void> filterByCategory(String? category) =>
      loadProducts(filter: state.filter.copyWith(category: category));

  Future<void> refresh() => loadProducts();

  Future<void> clearFilters() => loadProducts(filter: const ProductFilter());

  ProductEntity? getCachedProduct(String productId) => _productCache[productId];
}
