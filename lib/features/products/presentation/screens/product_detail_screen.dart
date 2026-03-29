import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:style_cart/app/router/app_router.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';
import 'package:style_cart/core/providers/repository_providers.dart';
import 'package:style_cart/core/utils/extensions.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/cart/data/models/cart_item_model.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';
import 'package:style_cart/features/products/presentation/providers/product_detail_notifier.dart';
import 'package:style_cart/features/wishlist/presentation/providers/wishlist_notifier.dart';
import 'package:style_cart/shared/utils/wishlist_helper.dart';
import 'package:style_cart/shared/widgets/images/safe_remote_image.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({required this.productId, super.key});
  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final PageController _imagePageController = PageController();

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  void _toggleWishlist(WidgetRef ref, ProductEntity product) {
    toggleWishlist(ref, context, product);
  }

  Future<void> _addToCart(BuildContext context, WidgetRef ref) async {
    final state = ref.read(productDetailNotifierProvider(widget.productId));
    final product = state.product;

    if (product == null) return;

    final error = ref
        .read(productDetailNotifierProvider(widget.productId).notifier)
        .validateSelection();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authState = ref.read(authNotifierProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    if (user == null) {
      context.push(RouteNames.login);
      return;
    }

    final cartItem = CartItemModel(
      cartItemId: CartItemModel.generateId(
        product.productId,
        state.selectedSize!,
        state.selectedColor ?? '',
      ),
      productId: product.productId,
      productName: product.name,
      brand: product.brand,
      imageUrl: product.thumbnailUrl,
      size: state.selectedSize!,
      color: state.selectedColor ?? '',
      colorHex: product.colors
          .firstWhere(
            (c) => c.name == state.selectedColor,
            orElse: () =>
                const ProductColorEntity(name: '', hexCode: '#000000'),
          )
          .hexCode,
      quantity: state.quantity,
      unitPrice: product.price,
      discountPct: product.discountPct,
      finalPrice: product.finalPrice,
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await ref
        .read(cartRepositoryProvider)
        .addToCart(userId: user.uid, item: cartItem);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: AppColors.error,
        ),
      ),
      (_) {
        if (!context.mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Added to cart!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: Colors.white,
              onPressed: () {
                if (AppRouter.navigatorKey.currentContext?.mounted ?? false) {
                  AppRouter.navigatorKey.currentContext?.pushNamed(
                    RouteNames.cart,
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _buyNow(BuildContext context, WidgetRef ref) async {
    await _addToCart(context, ref);
    if (context.mounted) context.push(RouteNames.cart);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailNotifierProvider(widget.productId));
    final isWishlisted = ref.watch(
      isProductWishlistedProvider(widget.productId),
    );
    final detailNotifier = ref.read(
      productDetailNotifierProvider(widget.productId).notifier,
    );

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    if (state.hasError || state.product == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage.isNotEmpty
                      ? state.errorMessage
                      : 'Product not found or unavailable',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'BACK TO HOME',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final product = state.product!;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ImageSection(
                  product: product,
                  state: state,
                  detailNotifier: detailNotifier,
                  imagePageController: _imagePageController,
                  context: context,
                ),
              ),
              SliverToBoxAdapter(child: _ProductInfoSection(product: product)),
              SliverToBoxAdapter(
                child: _SizeSelector(
                  product: product,
                  state: state,
                  detailNotifier: detailNotifier,
                ),
              ),
              if (product.colors.isNotEmpty)
                SliverToBoxAdapter(
                  child: _ColorSelector(
                    product: product,
                    state: state,
                    detailNotifier: detailNotifier,
                  ),
                ),
              SliverToBoxAdapter(child: _TabSection(product: product)),
              SliverToBoxAdapter(child: _ReviewsSection(product: product)),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomActionBar(
              product: product,
              state: state,
              onDecrement: detailNotifier.decrementQuantity,
              onIncrement: detailNotifier.incrementQuantity,
              onAddToCart: () => _addToCart(context, ref),
              onBuyNow: () => _buyNow(context, ref),
              context: context,
            ),
          ),
          _FloatingNavButtons(
            isWishlisted: isWishlisted,
            onWishlistTap: () => _toggleWishlist(ref, product),
          ),
        ],
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({
    required this.product,
    required this.state,
    required this.detailNotifier,
    required this.imagePageController,
    required this.context,
  });
  final ProductEntity product;
  final ProductDetailState state;
  final ProductDetailNotifier detailNotifier;
  final PageController imagePageController;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: Stack(
        children: [
          PageView.builder(
            controller: imagePageController,
            itemCount: product.imageUrls.length,
            onPageChanged: detailNotifier.setImageIndex,
            itemBuilder: (context, index) => SafeRemoteImage(
              imageUrl: product.imageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.backgroundDark],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                product.imageUrls.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: state.currentImageIndex == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: state.currentImageIndex == i
                        ? Colors.white
                        : Colors.white38,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavButtons extends StatelessWidget {
  const _FloatingNavButtons({
    required this.isWishlisted,
    required this.onWishlistTap,
  });
  final bool isWishlisted;
  final VoidCallback onWishlistTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleButton(icon: Icons.arrow_back, onTap: () => context.pop()),
              _CircleButton(
                icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
                iconColor: isWishlisted ? AppColors.gold : Colors.white,
                onTap: onWishlistTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
      ),
    );
  }
}

class _ProductInfoSection extends StatelessWidget {
  const _ProductInfoSection({required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.brand.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.gold,
                  letterSpacing: 2,
                ),
              ),
              _StockStatusBadge(status: product.stockStatus),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 28,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                product.finalPrice.toCurrencyString,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
              if (product.hasDiscount) ...[
                const SizedBox(width: 12),
                Text(
                  product.price.toCurrencyString,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-${product.discountPct}% OFF',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          if (product.isLimitedEdition)
            Text(
              'ONLY ${product.totalStock} LEFT',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
          if (product.reviewCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < product.avgRating.floor()
                          ? Icons.star
                          : Icons.star_border,
                      color: AppColors.gold,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${product.avgRating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StockStatusBadge extends StatelessWidget {
  const _StockStatusBadge({required this.status});
  final StockStatus status;

  @override
  Widget build(BuildContext context) {
    Color getStatusColor() {
      if (status == StockStatus.inStock) return AppColors.inStock;
      if (status == StockStatus.low) return AppColors.warning;
      return AppColors.outOfStock;
    }

    final color = getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  const _SizeSelector({
    required this.product,
    required this.state,
    required this.detailNotifier,
  });
  final ProductEntity product;
  final ProductDetailState state;
  final ProductDetailNotifier detailNotifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT SIZE',
            style: AppTextStyles.labelSmall.copyWith(
              letterSpacing: 1,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ProductSize.all.map((size) {
                final isAvailable = product.isSizeAvailable(size);
                final isSelected = state.selectedSize == size;

                return GestureDetector(
                  onTap: isAvailable
                      ? () => detailNotifier.selectSize(size)
                      : null,
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.backgroundCard,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.gold
                            : isAvailable
                            ? AppColors.borderDefault
                            : AppColors.textMuted.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          size,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.gold
                                : isAvailable
                                ? Colors.white
                                : AppColors.textMuted,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (!isAvailable)
                          Positioned.fill(
                            child: CustomPaint(painter: _CrossOutPainter()),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (state.selectedSize != null) ...[
            const SizedBox(height: 8),
            Text(
              '${product.stockForSize(state.selectedSize!)} units available',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CrossOutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted.withOpacity(0.5)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ColorSelector extends StatelessWidget {
  const _ColorSelector({
    required this.product,
    required this.state,
    required this.detailNotifier,
  });
  final ProductEntity product;
  final ProductDetailState state;
  final ProductDetailNotifier detailNotifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COLOR',
            style: AppTextStyles.labelSmall.copyWith(
              letterSpacing: 1,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: product.colors.map((color) {
                final isSelected = state.selectedColor == color.name;
                return GestureDetector(
                  onTap: () => detailNotifier.selectColor(color.name),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          color.hexCode.replaceFirst('#', 'FF'),
                          radix: 16,
                        ),
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              const BoxShadow(
                                color: Colors.white24,
                                blurRadius: 6,
                              ),
                            ]
                          : [],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (state.selectedColor != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.selectedColor!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabSection extends StatelessWidget {
  const _TabSection({required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: AppTextStyles.labelMedium.copyWith(letterSpacing: 1),
            tabs: [
              const Tab(text: 'DESCRIPTION'),
              Tab(text: 'REVIEWS (${product.reviewCount})'),
            ],
          ),
          SizedBox(
            height:
                200, // Fixed height for simple tab content without tricky scroll physics
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    product.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.7,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'No reviews yet',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Integrated in tabs
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.product,
    required this.state,
    required this.onDecrement,
    required this.onIncrement,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.context,
  });
  final ProductEntity product;
  final ProductDetailState state;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.97),
        border: const Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Row(
        children: [
          if (state.selectedSize != null) ...[
            _QuantitySelector(
              quantity: state.quantity,
              onDecrement: onDecrement,
              onIncrement: onIncrement,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: product.isOutOfStock ? null : onAddToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                product.isOutOfStock ? 'OUT OF STOCK' : 'ADD TO CART',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: product.isOutOfStock ? null : onBuyNow,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.gold),
              foregroundColor: AppColors.gold,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              'BUY NOW',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyButton(icon: Icons.remove, onTap: onDecrement),
        const SizedBox(width: 16),
        Text(
          '$quantity',
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        const SizedBox(width: 16),
        _QtyButton(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
