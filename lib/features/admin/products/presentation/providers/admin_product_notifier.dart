import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/features/admin/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:style_cart/features/home/presentation/providers/home_providers.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/products/data/providers/product_data_providers.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';
import 'package:style_cart/features/products/domain/entities/product_filter_entity.dart';
import 'package:style_cart/features/products/domain/usecases/create_product_usecase.dart';
import 'package:style_cart/features/products/domain/usecases/update_inventory_usecase.dart';
import 'package:style_cart/features/products/domain/usecases/update_product_usecase.dart';
import 'package:style_cart/features/products/presentation/providers/paginated_product_notifier.dart';
import 'package:style_cart/features/products/presentation/providers/product_list_notifier.dart';

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
    // Initial load - defer to next microtask to avoid state modification during build
    Future.microtask(_loadProducts);
    return const AdminProductState(isLoading: true);
  }

  Future<void> _loadProducts() async {
    state = state.copyWith(isLoading: true, hasError: false);

    // Load all products (including inactive) using repository directly to bypass standard filters
    final result = await ref
        .read(productRepositoryProvider)
        .getProducts(filter: const ProductFilter(pageSize: 100));

    // Load low stock products
    final threshold =
        int.tryParse(dotenv.env['LOW_STOCK_THRESHOLD']?.trim() ?? '5') ?? 5;
    final lowStockResult = await ref
        .read(getLowStockProductsUseCaseProvider)
        .call(threshold);

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
    debugPrint(
      'AdminProductNotifier: Starting product creation for ${product.name}',
    );

    final result = await ref
        .read(createProductUseCaseProvider)
        .call(
          CreateProductParams(
            product: product,
            imageLocalPaths: imageLocalPaths,
          ),
        );

    state = state.copyWith(isSaving: false);

    if (result.isLeft()) {
      debugPrint(
        'AdminProductNotifier: Creation FAILED - '
        '${result.swap().getOrElse(() => const ServerFailure()).message}',
      );
      return result;
    }

    final productId = result.getOrElse(() => '');
    debugPrint('AdminProductNotifier: Creation SUCCESS - ID: $productId');
    await _loadProducts();
    _refreshProductConsumers();

    return result;
  }

  // Update product
  Future<Either<Failure, void>> updateProduct({
    required ProductEntity product,
    required List<String> newImagePaths,
    required List<String> removedUrls,
  }) async {
    state = state.copyWith(isSaving: true);
    debugPrint(
      'AdminProductNotifier: Starting product update for ${product.productId}',
    );

    final result = await ref
        .read(updateProductUseCaseProvider)
        .call(
          UpdateProductParams(
            product: product,
            newImageLocalPaths: newImagePaths,
            removedImageUrls: removedUrls,
          ),
        );

    state = state.copyWith(isSaving: false);

    if (result.isLeft()) {
      debugPrint(
        'AdminProductNotifier: Update FAILED - '
        '${result.swap().getOrElse(() => const ServerFailure()).message}',
      );
      return result;
    }

    debugPrint('AdminProductNotifier: Update SUCCESS');
    await _loadProducts();
    _refreshProductConsumers();

    return result;
  }

  // Toggle product status
  Future<void> toggleStatus(String productId, bool isActive) async {
    await ref
        .read(productRepositoryProvider)
        .toggleProductStatus(productId, isActive);
    await _loadProducts();
    _refreshProductConsumers();
  }

  // Update inventory
  Future<Either<Failure, void>> updateInventory({
    required String productId,
    required Map<String, int> inventory,
  }) async {
    final result = await ref
        .read(updateInventoryUseCaseProvider)
        .call(
          UpdateInventoryParams(productId: productId, inventory: inventory),
        );
    if (result.isRight()) {
      await _loadProducts();
      _refreshProductConsumers();
    }
    return result;
  }

  Future<Either<Failure, void>> deleteProduct(String productId) async {
    state = state.copyWith(isDeleting: true, hasError: false, errorMessage: '');
    debugPrint('AdminProductNotifier: Starting product delete for $productId');

    final result = await ref
        .read(productRepositoryProvider)
        .deleteProduct(productId);

    state = state.copyWith(
      isDeleting: false,
      hasError: result.isLeft(),
      errorMessage: result.fold((failure) => failure.message, (_) => ''),
    );

    if (result.isLeft()) {
      debugPrint(
        'AdminProductNotifier: Delete FAILED - '
        '${result.swap().getOrElse(() => const ServerFailure()).message}',
      );
      return result;
    }

    debugPrint('AdminProductNotifier: Delete SUCCESS');
    await _loadProducts();
    _refreshProductConsumers();

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

  void _refreshProductConsumers() {
    ref.invalidate(productListNotifierProvider);
    ref.invalidate(paginatedProductNotifierProvider);
    ref.invalidate(featuredProductsProvider);
    ref.invalidate(newArrivalProductsProvider);
    ref.invalidate(bestSellerProductsProvider);
    ref.invalidate(lowStockCountProvider);
    ref.invalidate(adminLowStockCountProvider);
  }
}
