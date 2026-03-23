import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:style_cart/app/theme/app_colors.dart';
// Note: AppDimensions, AppTextStyles and extensions will be added during analyze fix
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/app/theme/app_dimensions.dart';
import 'package:style_cart/core/utils/extensions.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';

class ProductCardWidget extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback? onWishlistTap;
  final bool isWishlisted;
  final double imageAspectRatio;

  const ProductCardWidget({
    required this.product,
    required this.onTap,
    this.onWishlistTap,
    this.isWishlisted = false,
    this.imageAspectRatio = 0.8,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image container ──────────────────────
          Stack(
            children: [
              AspectRatio(
                aspectRatio: imageAspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radius16 ?? 16.0,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _buildShimmer(),
                    errorWidget: (_, __, ___) => _buildErrorPlaceholder(),
                  ),
                ),
              ),

              // Discount badge (top-left)
              if (product.hasDiscount && product.discountPct > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: _DiscountBadge(
                    pct: product.discountPct,
                  ),
                ),

              // Stock status badge (top-left, below discount)
              if (product.isLowStock || product.isOutOfStock)
                Positioned(
                  top: (product.hasDiscount && product.discountPct > 0) ? 36 : 8,
                  left: 8,
                  child: _StockBadge(
                    status: product.stockStatus,
                  ),
                ),

              // Wishlist button (top-right)
              Positioned(
                top: 8,
                right: 8,
                child: _WishlistButton(
                  isWishlisted: isWishlisted,
                  onTap: onWishlistTap,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Category label
          Text(
            product.category.toUpperCase(),
            style: AppTextStyles.labelSmall?.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ) ?? const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),

          const SizedBox(height: 2),

          // Product name
          Text(
            product.name,
            style: AppTextStyles.titleMedium ?? const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Price row
          _PriceRow(product: product),

          // Rating row (if has reviews)
          if (product.reviewCount > 0)
            _RatingRow(product: product),
        ],
      ),
    );
  }
}

// ── Internal sub-widgets ──────────────────────────────

class _DiscountBadge extends StatelessWidget {
  final int pct;
  const _DiscountBadge({required this.pct});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 8, vertical: 4,
    ),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      '-$pct%',
      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}

class _StockBadge extends StatelessWidget {
  final StockStatus status;
  const _StockBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    // We assume warning color is orange.
    final color = status == StockStatus.low
        ? AppColors.warning
        : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6, vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.labelSmall?.copyWith(
          color: Colors.white,
          fontSize: 9,
        ) ?? const TextStyle(color: Colors.white, fontSize: 9),
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  final bool isWishlisted;
  final VoidCallback? onTap;
  const _WishlistButton({
    required this.isWishlisted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark, // using a dark background color
        shape: BoxShape.circle,
      ),
      child: Icon(
        isWishlisted ? Icons.favorite : Icons.favorite_border,
        color: isWishlisted ? AppColors.primary : Colors.white,
        size: 18,
      ),
    ),
  );
}

class _PriceRow extends StatelessWidget {
  final ProductEntity product;
  const _PriceRow({required this.product});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        '\$${product.finalPrice.toStringAsFixed(2)}', // Assuming toCurrencyString
        style: const TextStyle(color: AppColors.primary, fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold),
      ),
      if (product.hasDiscount && product.discountPct > 0) ...[
        const SizedBox(width: 6),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: AppTextStyles.bodySmall?.copyWith(
            color: AppColors.textMuted,
            decoration: TextDecoration.lineThrough,
          ) ?? const TextStyle(color: AppColors.textMuted, fontSize: 12, decoration: TextDecoration.lineThrough),
        ),
      ],
    ],
  );
}

class _RatingRow extends StatelessWidget {
  final ProductEntity product;
  const _RatingRow({required this.product});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(
        Icons.star, color: Colors.orangeAccent, size: 14, // using internal bright color
      ),
      const SizedBox(width: 4),
      Text(
        product.avgRating.toStringAsFixed(1),
        style: AppTextStyles.labelMedium?.copyWith(
          color: AppColors.textSecondary,
        ) ?? const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    ],
  );
}

Widget _buildShimmer() => Shimmer.fromColors(
  baseColor: AppColors.backgroundLight,
  highlightColor: AppColors.backgroundDark,
  child: Container(color: AppColors.backgroundLight),
);

Widget _buildErrorPlaceholder() => Container(
  color: AppColors.backgroundLight,
  child: const Icon(
    Icons.image_not_supported_outlined,
    color: AppColors.textMuted,
  ),
);
