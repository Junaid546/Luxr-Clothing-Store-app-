import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/core/providers/repository_providers.dart';
import 'package:style_cart/core/utils/extensions.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/cart/data/models/cart_item_model.dart';
import 'package:style_cart/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:style_cart/features/wishlist/presentation/providers/wishlist_notifier.dart';
import 'package:style_cart/shared/widgets/images/safe_remote_image.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  String _selectedTab = 'All Items';
  final List<String> _categories = [
    'All Items',
    'Apparel',
    'Footwear',
    'Accessories',
  ];

  Future<void> _quickAddToCart(
    BuildContext context,
    WidgetRef ref,
    WishlistItemModel item,
  ) async {
    final authState = ref.read(authNotifierProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    if (user == null) {
      context.push(RouteNames.login);
      return;
    }

    final cartItem = CartItemModel(
      cartItemId: CartItemModel.generateId(item.productId, 'Standard', ''),
      productId: item.productId,
      productName: item.productName,
      brand: item.brand,
      imageUrl: item.imageUrl,
      size: 'Standard',
      color: '',
      colorHex: '#000000',
      quantity: 1,
      unitPrice: item.price,
      discountPct: item.discountPct,
      finalPrice: item.finalPrice,
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await ref
        .read(cartRepositoryProvider)
        .addToCart(userId: user.uid, item: cartItem);

    if (context.mounted) {
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        ),
        (_) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to cart!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
          // Auto remove from wishlist after adding to cart
          ref
              .read(wishlistNotifierProvider.notifier)
              .removeFromWishlist(item.productId);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(wishlistNotifierProvider);
    final items = wishlistState.items;

    if (wishlistState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    if (items.isEmpty) {
      return _buildEmptyState(context);
    }

    final filtered = _selectedTab == 'All Items'
        ? items
        : items
              .where(
                (item) =>
                    item.category.toLowerCase() == _selectedTab.toLowerCase(),
              )
              .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Wishlist',
              style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
            ),
            Text(
              '${filtered.length} ITEMS',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(RouteNames.shop),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => context.push(RouteNames.shop),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _WishlistGrid(
              filteredItems: filtered,
              onRemove: (id) => ref
                  .read(wishlistNotifierProvider.notifier)
                  .removeFromWishlist(id),
              onAddToCart: (item) => _quickAddToCart(context, ref, item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(RouteNames.shop),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 80,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 20),
            Text(
              'Your wishlist is empty',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save items you love to buy later',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push(RouteNames.shop),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Explore Products',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedTab == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                cat,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WishlistGrid extends StatelessWidget {
  const _WishlistGrid({
    required this.filteredItems,
    required this.onRemove,
    required this.onAddToCart,
  });
  final List<WishlistItemModel> filteredItems;
  final void Function(String) onRemove;
  final void Function(WishlistItemModel) onAddToCart;

  @override
  Widget build(BuildContext context) {
    if (filteredItems.isEmpty) {
      return Center(
        child: Text(
          'No items in this category',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    // Chunk items into rows, treating limited edition items as their own row
    final rows = <Widget>[];
    for (var i = 0; i < filteredItems.length;) {
      final item = filteredItems[i];
      if (item.isLimitedEdition) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _LimitedEditionCard(
              item: item,
              onRemove: () => onRemove(item.productId),
              onAddToCart: () => onAddToCart(item),
            ),
          ),
        );
        i++;
      } else {
        // Collect up to two standard items
        final rowItems = <WishlistItemModel>[item];
        i++;
        if (i < filteredItems.length && !filteredItems[i].isLimitedEdition) {
          rowItems.add(filteredItems[i]);
          i++;
        }
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StandardWishlistCard(
                    item: rowItems[0],
                    onRemove: () => onRemove(rowItems[0].productId),
                    onAddToCart: () => onAddToCart(rowItems[0]),
                  ),
                ),
                const SizedBox(width: 16),
                if (rowItems.length > 1)
                  Expanded(
                    child: _StandardWishlistCard(
                      item: rowItems[1],
                      onRemove: () => onRemove(rowItems[1].productId),
                      onAddToCart: () => onAddToCart(rowItems[1]),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
        );
      }
    }

    return ListView(padding: const EdgeInsets.all(16), children: rows);
  }
}

class _StandardWishlistCard extends StatelessWidget {
  const _StandardWishlistCard({
    required this.item,
    required this.onRemove,
    required this.onAddToCart,
  });
  final WishlistItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SafeRemoteImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: Container(color: AppColors.backgroundCard),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: AppColors.gold,
                    size: 18,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: onAddToCart,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          item.category.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.productName,
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          item.finalPrice.toCurrencyString,
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _LimitedEditionCard extends StatelessWidget {
  const _LimitedEditionCard({
    required this.item,
    required this.onRemove,
    required this.onAddToCart,
  });
  final WishlistItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
          // Swipe left
          onAddToCart();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SafeRemoteImage(
                imageUrl: item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorWidget: Container(color: AppColors.backgroundLight),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIMITED EDITION',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.productName,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.finalPrice.toCurrencyString,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Column(
                children: [
                  const Icon(Icons.favorite, color: AppColors.gold, size: 24),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.touch_app_outlined,
                        color: AppColors.textMuted,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Swipe',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
