import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';
import 'package:style_cart/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:style_cart/features/wishlist/presentation/providers/wishlist_notifier.dart';

Future<void> toggleWishlist(
  WidgetRef ref,
  BuildContext context,
  ProductEntity product,
) async {
  final authState = ref.read(authNotifierProvider);
  final bool isAuthenticated = authState is AuthAuthenticated;

  if (!isAuthenticated) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please sign in to save items'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.push(RouteNames.login);
    return;
  }

  final isWishlisted = ref.read(isProductWishlistedProvider(product.productId));
  final notifier = ref.read(wishlistNotifierProvider.notifier);

  if (isWishlisted) {
    await notifier.removeFromWishlist(product.productId);
  } else {
    final item = WishlistItemModel(
      productId: product.productId,
      productName: product.name,
      brand: product.brand,
      imageUrl: product.thumbnailUrl,
      price: product.price,
      discountPct: product.discountPct,
      finalPrice: product.finalPrice,
      category: product.category,
      isLimitedEdition: product.isLimitedEdition,
      addedAt: DateTime.now(),
    );
    await notifier.addToWishlist(item);
  }
}
