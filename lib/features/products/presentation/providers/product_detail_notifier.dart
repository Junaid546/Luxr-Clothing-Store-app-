// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stylecart/features/products/data/providers/product_data_providers.dart';
import 'package:stylecart/features/products/domain/entities/product_entity.dart';

part 'product_detail_notifier.freezed.dart';
part 'product_detail_notifier.g.dart';

@freezed
class ProductDetailState with _$ProductDetailState {
  const factory ProductDetailState({
    ProductEntity? product,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    @Default('') String errorMessage,
    String? selectedSize,
    String? selectedColor,
    @Default(1) int quantity,
    @Default(0) int currentImageIndex,
    @Default(false) bool isWishlisted,
  }) = _ProductDetailState;
}

@riverpod
class ProductDetailNotifier extends _$ProductDetailNotifier {
  StreamSubscription<dynamic>? _productSubscription;

  @override
  ProductDetailState build(String productId) {
    // Register dispose FIRST before any subscriptions
    ref.onDispose(() {
      _productSubscription?.cancel();
      _productSubscription = null;
    });

    // Schedule stream subscription AFTER the current build phase completes
    // This prevents "setState called during build" assertion errors
    Timer.run(() => _watchProduct(productId));

    return const ProductDetailState(isLoading: true);
  }

  void _watchProduct(String productId) {
    _productSubscription?.cancel();
    _productSubscription =
        ref.read(productRepositoryProvider).watchProduct(productId).listen(
      (result) {
        result.fold(
          (failure) {
            state = state.copyWith(
              isLoading: false,
              hasError: true,
              errorMessage: failure.message,
            );
          },
          (product) {
            // Auto-select first available size
            final firstAvailableSize = product.inventory.entries
                .where((e) => e.value > 0)
                .map((e) => e.key)
                .firstOrNull;

            // Auto-select first color
            final firstColor =
                product.colors.isNotEmpty ? product.colors.first.name : null;

            state = state.copyWith(
              isLoading: false,
              product: product,
              selectedSize: state.selectedSize ?? firstAvailableSize,
              selectedColor: state.selectedColor ?? firstColor,
            );
          },
        );
      },
      onError: (Object e) {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: e.toString(),
        );
      },
    );
  }

  void selectSize(String size) {
    if (state.product?.isSizeAvailable(size) == true) {
      state = state.copyWith(selectedSize: size);
    }
  }

  void selectColor(String color) =>
      state = state.copyWith(selectedColor: color);

  void incrementQuantity() {
    final maxStock = state.product?.stockForSize(
          state.selectedSize ?? '',
        ) ??
        0;
    if (state.quantity < maxStock && state.quantity < 10) {
      state = state.copyWith(quantity: state.quantity + 1);
    }
  }

  void decrementQuantity() {
    if (state.quantity > 1) {
      state = state.copyWith(quantity: state.quantity - 1);
    }
  }

  void setImageIndex(int index) =>
      state = state.copyWith(currentImageIndex: index);

  void setWishlisted(bool value) => state = state.copyWith(isWishlisted: value);

  // Validation before add to cart
  String? validateSelection() {
    if (state.selectedSize == null) {
      return 'Please select a size';
    }
    if (state.selectedColor == null &&
        (state.product?.colors.isNotEmpty ?? false)) {
      return 'Please select a color';
    }
    if (state.product?.isOutOfStock ?? true) {
      return 'This product is out of stock';
    }
    return null; // valid
  }
}
