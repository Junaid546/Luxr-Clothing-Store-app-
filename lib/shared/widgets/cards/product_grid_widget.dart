import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';
import 'package:style_cart/shared/widgets/cards/product_card_widget.dart';

class ProductGridWidget extends ConsumerStatefulWidget {
  final List<ProductEntity> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String errorMessage;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRetry;

  const ProductGridWidget({
    required this.products,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage = '',
    this.onLoadMore,
    this.onRetry,
    super.key,
  });

  @override
  ConsumerState<ProductGridWidget> createState() => _ProductGridWidgetState();
}

class _ProductGridWidgetState extends ConsumerState<ProductGridWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Trigger load more when 200px from bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.onLoadMore?.call();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _buildShimmerGrid();
    if (widget.hasError && widget.products.isEmpty) {
      return _buildError();
    }
    if (widget.products.isEmpty) return _buildEmpty();

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemCount: widget.products.length + (widget.isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.products.length) {
          return _buildShimmerCard();
        }
        final product = widget.products[index];
        return ProductCardWidget(
          product: product,
          onTap: () => context.push(
            RouteNames.productDetail.replaceAll(':productId', product.productId),
          ),
        );
      },
    );
  }

  Widget _buildShimmerGrid() => GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.6,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => _buildShimmerCard(),
      );

  Widget _buildShimmerCard() => Shimmer.fromColors(
        baseColor: AppColors.backgroundLight,
        highlightColor: AppColors.backgroundDark,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: AppTextStyles.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ) ?? const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: AppTextStyles.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ) ?? const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(widget.errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
}
