import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/products/data/providers/product_data_providers.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';
import 'package:style_cart/features/products/domain/entities/product_filter_entity.dart';
import 'package:style_cart/features/products/domain/usecases/create_product_usecase.dart';
import 'package:style_cart/features/products/domain/usecases/get_low_stock_products_usecase.dart';
import 'package:style_cart/features/products/domain/usecases/update_inventory_usecase.dart';
import 'package:style_cart/features/products/domain/usecases/update_product_usecase.dart';

part 'admin_product_notifier.freezed.dart';
part 'admin_product_notifier.g.dart';

@freezed
class AdminProductState with _$AdminProductState {
  const factory AdminProductState({
    @Default([]) List<ProductEntity> products,
    @Default([]) List<ProductEntity> lowStockProducts,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    @Default(false) bool isDeleting,
    @Default(false) bool hasError,
    @Default('') String errorMessage,
    @Default('all') String activeTab,
    // 'all' | 'low_stock' | 'categories'
    @Default('') String searchQuery,
  }) = _AdminProductState;
}

@riverpod
class AdminProductNotifier extends _$AdminProductNotifier {
  @override
  AdminProductState build() {
    _loadProducts();
    return const AdminProductState(isLoading: true);
  }

  Future<void> _loadProducts() async {
    state = state.copyWith(isLoading: true, hasError: false);

    // Load all products (including inactive) using repository directly to bypass standard filters
    final result = await ref.read(productRepositoryProvider).getProducts(
          filter: const ProductFilter(
            pageSize: 100,
            sortBy: 'newest',
          ),
        );

    // Load low stock products
    final threshold = int.parse(
      dotenv.env['LOW_STOCK_THRESHOLD'] ?? '5',
    );
    final lowStockResult =
        await ref.read(getLowStockProductsUseCaseProvider).call(threshold);

    state = state.copyWith(
      isLoading: false,
      products: result.getOrElse(() => []),
      lowStockProducts: lowStockResult.getOrElse(() => []),
    );
  }

  // Create product
  Future<Either<Failure, String>> createProduct({
    required ProductEntity product,
    required List<String> imageLocalPaths,
  }) async {
    state = state.copyWith(isSaving: true);

    final result = await ref.read(createProductUseCaseProvider).call(
          CreateProductParams(
            product: product,
            imageLocalPaths: imageLocalPaths,
          ),
        );

    state = state.copyWith(isSaving: false);

    if (result.isRight()) {
      await _loadProducts(); // refresh list
    }

    return result;
  }

  // Update product
  Future<Either<Failure, void>> updateProduct({
    required ProductEntity product,
    required List<String> newImagePaths,
    required List<String> removedUrls,
  }) async {
    state = state.copyWith(isSaving: true);

    final result = await ref.read(updateProductUseCaseProvider).call(
          UpdateProductParams(
            product: product,
            newImageLocalPaths: newImagePaths,
            removedImageUrls: removedUrls,
          ),
        );

    state = state.copyWith(isSaving: false);

    if (result.isRight()) {
      await _loadProducts();
    }

    return result;
  }

  // Toggle product status
  Future<void> toggleStatus(
    String productId,
    bool isActive,
  ) async {
    await ref
        .read(productRepositoryProvider)
        .toggleProductStatus(productId, isActive);
    await _loadProducts();
  }

  // Update inventory
  Future<Either<Failure, void>> updateInventory({
    required String productId,
    required Map<String, int> inventory,
  }) async {
    final result = await ref.read(updateInventoryUseCaseProvider).call(
          UpdateInventoryParams(
            productId: productId,
            inventory: inventory,
          ),
        );
    if (result.isRight()) await _loadProducts();
    return result;
  }

  void setActiveTab(String tab) => state = state.copyWith(activeTab: tab);

  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);

  // Filtered products
  List<ProductEntity> get filteredProducts {
    var list = state.activeTab == 'low_stock'
        ? state.lowStockProducts
        : state.products;

    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      list = list
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.brand.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q),
          )
          .toList();
    }

    return list;
  }

  Future<void> refresh() => _loadProducts();
}
