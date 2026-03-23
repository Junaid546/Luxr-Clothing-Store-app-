// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/features/products/data/providers/product_data_providers.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';
import 'package:style_cart/features/products/domain/entities/product_filter_entity.dart';
import 'package:style_cart/features/products/domain/usecases/get_products_usecase.dart';

part 'product_list_notifier.freezed.dart';
part 'product_list_notifier.g.dart';

@freezed
class ProductListState with _$ProductListState {
  const factory ProductListState({
    @Default([])  List<ProductEntity> products,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasMore,
    @Default(false) bool hasError,
    @Default('') String errorMessage,
    @Default(ProductFilter()) ProductFilter filter,
    Object? lastDocument, // Firestore cursor
  }) = _ProductListState;
}

@riverpod
class ProductListNotifier extends _$ProductListNotifier {

  static const int _pageSize = 20;

  @override
  ProductListState build() => const ProductListState(
    hasMore: true,
    filter: ProductFilter(pageSize: _pageSize),
  );

  // ── Initial load / refresh ────────────────────────
  Future<void> loadProducts({ProductFilter? filter}) async {
    final activeFilter = filter ?? state.filter;

    state = state.copyWith(
      isLoading: true,
      hasError: false,
      products: [],
      lastDocument: null,
      hasMore: true,
      filter: activeFilter,
    );

    final result = await ref
        .read(getProductsUseCaseProvider)
        .call(GetProductsParams(
          filter: activeFilter,
        ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: failure.message,
      ),
      (products) => state = state.copyWith(
        isLoading: false,
        products: products,
        hasMore: products.length >= _pageSize,
        // Store last document for pagination cursor
        // Note: we need DocumentSnapshot — this comes
        // from the repository layer. Pass through model.
        lastDocument: products.isNotEmpty ? products.last : null,
      ),
    );
  }

  // ── Load more (infinite scroll) ───────────────────
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final result = await ref
        .read(getProductsUseCaseProvider)
        .call(GetProductsParams(
          filter: state.filter,
          lastDocumentSnapshot: state.lastDocument,
        ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingMore: false,
        hasError: true,
        errorMessage: failure.message,
      ),
      (newProducts) => state = state.copyWith(
        isLoadingMore: false,
        products: [...state.products, ...newProducts],
        hasMore: newProducts.length >= _pageSize,
        lastDocument: newProducts.isNotEmpty
            ? newProducts.last
            : state.lastDocument,
      ),
    );
  }

  // ── Apply filter ──────────────────────────────────
  Future<void> applyFilter(ProductFilter filter) =>
      loadProducts(filter: filter);

  // ── Update sort ───────────────────────────────────
  Future<void> sortBy(String sortKey) =>
      loadProducts(filter: state.filter.copyWith(
        sortBy: sortKey,
      ));

  // ── Clear filters ─────────────────────────────────
  Future<void> clearFilters() =>
      loadProducts(filter: const ProductFilter());

  // ── Toggle category ───────────────────────────────
  Future<void> filterByCategory(String? category) =>
      loadProducts(filter: state.filter.copyWith(
        category: category,
      ));

  // ── Refresh (pull-to-refresh) ─────────────────────
  Future<void> refresh() => loadProducts();
}
