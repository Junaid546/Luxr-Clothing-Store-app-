import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/core/utils/extensions.dart';
import 'package:style_cart/features/admin/core/providers/admin_guard_provider.dart';
import 'package:style_cart/features/admin/products/presentation/providers/admin_product_notifier.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guardState = ref.watch(adminGuardProvider);

    // 1. Handle Guard Loading/Error States
    if (guardState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (guardState.hasError) {
      return Center(child: Text('Error: ${guardState.error}'));
    }

    // 2. Handle Unauthorized
    final isAdmin = guardState.valueOrNull ?? false;
    if (!isAdmin) return const SizedBox.shrink();

    // 3. Watch State (only if admin)
    final state = ref.watch(adminProductNotifierProvider);
    final notifier = ref.read(adminProductNotifierProvider.notifier);
    final products = notifier.filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.adminAddProduct),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            if (_showSearch) _buildSearchBar(notifier),
            _buildTabsRow(state, notifier),
            _buildStatsRow(state),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : products.isEmpty
                      ? _buildEmptyState()
                      : _buildProductsList(products, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            'LUXR Inventory',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchController.clear();
                ref.read(adminProductNotifierProvider.notifier).setSearchQuery('');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () => _showCategoryFilter(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AdminProductNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: notifier.setSearchQuery,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search products, brands...',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.backgroundCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabsRow(AdminProductState state, AdminProductNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _AdminTab(
            label: 'All Items',
            tabKey: 'all',
            isActive: state.activeTab == 'all',
            onTap: () => notifier.setActiveTab('all'),
          ),
          _AdminTab(
            label: 'Low Stock',
            tabKey: 'low_stock',
            isActive: state.activeTab == 'low_stock',
            badgeCount: state.lowStockProducts.length,
            badgeColor: AppColors.error,
            onTap: () => notifier.setActiveTab('low_stock'),
          ),
          _AdminTab(
            label: 'Categories',
            tabKey: 'categories',
            isActive: state.activeTab == 'categories',
            onTap: () => notifier.setActiveTab('categories'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AdminProductState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            '${state.products.length} TOTAL ITEMS',
            style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.5),
          ),
          const Spacer(),
          if (state.lowStockProducts.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${state.lowStockProducts.length} NEEDS ATTENTION',
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<ProductEntity> products, AdminProductNotifier notifier) {
    return RefreshIndicator(
      onRefresh: notifier.refresh,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _AdminProductTile(
            product: products[index],
            onLongPress: () => _showOptions(context, products[index], notifier),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showCategoryFilter(BuildContext context) {
    // TODO: Implement category filter sheet
  }

  void _showOptions(BuildContext context, ProductEntity product, AdminProductNotifier notifier) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                product.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white,
              ),
              title: Text(
                product.isActive ? 'Set Inactive' : 'Set Active',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                notifier.toggleStatus(product.productId, !product.isActive);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_road_outlined, color: Colors.white),
              title: const Text('Update Stock', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show quick stock update dialog
              },
            ),
            const Divider(color: AppColors.borderDefault),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Product', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, product, notifier);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductEntity product, AdminProductNotifier notifier) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Delete Product?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement delete in repository/notifier if needed
              // For now we use status toggle usually
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _AdminTab extends StatelessWidget {
  final String label;
  final String tabKey;
  final bool isActive;
  final int? badgeCount;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _AdminTab({
    required this.label,
    required this.tabKey,
    required this.isActive,
    this.badgeCount,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdminProductTile extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onLongPress;

  const _AdminProductTile({
    required this.product,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = product.totalStock <= product.lowStockThreshold && product.totalStock > 0;
    final bool isOutOfStock = product.totalStock == 0;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOutOfStock
                ? AppColors.error.withOpacity(0.4)
                : isLowStock
                    ? AppColors.warning.withOpacity(0.4)
                    : AppColors.borderDefault,
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: product.thumbnailUrl,
                    width: 60,
                    height: 68,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppColors.backgroundElevated),
                    errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                  ),
                ),
                if (!product.isActive)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'HIDDEN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.gold.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.finalPrice.toCurrencyString,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOutOfStock
                              ? AppColors.error
                              : isLowStock
                                  ? AppColors.warning
                                  : AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'STOCK: ${product.totalStock}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOutOfStock
                              ? AppColors.error
                              : isLowStock
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push(
                RouteNames.adminEditProduct.replaceAll(':productId', product.productId),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
