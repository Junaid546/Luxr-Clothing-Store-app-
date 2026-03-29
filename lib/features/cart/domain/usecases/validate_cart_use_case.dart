import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/providers/repository_providers.dart';
import 'package:style_cart/features/cart/data/models/cart_item_model.dart';
import 'package:style_cart/features/cart/domain/entities/cart_entity.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';

part 'validate_cart_use_case.g.dart';

class ValidateCartParams {

  const ValidateCartParams({
    required this.userId,
    required this.cartItems,
  });
  final String userId;
  final List<CartItemModel> cartItems;
}

@riverpod
class ValidateCartUseCase extends _$ValidateCartUseCase {
  @override
  void build() {}

  Future<Either<Failure, CartValidationResult>> call(ValidateCartParams params) async {
    final productRepo = ref.read(productRepositoryProvider);
    
    // 1. Get live products for all IDs in cart
    final productIds = params.cartItems.map((i) => i.productId).toSet().toList();
    final productsResult = await productRepo.getProductsByIds(productIds);

    return productsResult.fold(
      Left<Failure, CartValidationResult>.new,
      (List<ProductEntity> products) {
        final validatedItems = <CartItemModel>[];
        final stockIssues = <StockIssue>[];
        final priceChanges = <PriceChange>[];

        final productMap = {for (final p in products) p.productId: p};

        for (final cartItem in params.cartItems) {
          final product = productMap[cartItem.productId];

          // ── Case 1: Product no longer exists ────────
          if (product == null || !product.isActive) {
            stockIssues.add(StockIssue(
              productId: cartItem.productId,
              productName: cartItem.productName,
              size: cartItem.size,
              requested: cartItem.quantity,
              available: 0,
              reason: '${cartItem.productName} is no longer available.',
            ));
            continue;
          }

          // ── Case 2: Check Stock ─────────────────────
          final availableStock = product.inventory[cartItem.size] ?? 0;
          if (availableStock < cartItem.quantity) {
            stockIssues.add(StockIssue(
              productId: cartItem.productId,
              productName: cartItem.productName,
              size: cartItem.size,
              requested: cartItem.quantity,
              available: availableStock,
              reason: availableStock == 0 
                ? '${product.name} (Size ${cartItem.size}) is sold out.'
                : 'Only $availableStock left in ${product.name} (Size ${cartItem.size}).',
            ));
          }

          // ── Case 3: Check Price Changes ─────────────
          if (product.finalPrice != cartItem.finalPrice) {
            priceChanges.add(PriceChange(
              productId: cartItem.productId,
              productName: cartItem.productName,
              oldPrice: cartItem.finalPrice,
              newPrice: product.finalPrice,
            ));
          }

          // ── Build Validated Item (Snap live data) ───
          validatedItems.add(cartItem.copyWith(
            productName: product.name,
            unitPrice: product.price,
            discountPct: product.discountPct,
            finalPrice: product.finalPrice,
          ));
        }

        return Right<Failure, CartValidationResult>(CartValidationResult(
          validatedItems: validatedItems,
          stockIssues: stockIssues,
          priceChanges: priceChanges,
        ));
      },
    );
  }
}
