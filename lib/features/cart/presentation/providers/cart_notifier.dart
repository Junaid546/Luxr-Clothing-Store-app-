import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/providers/repository_providers.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/cart/data/models/cart_item_model.dart';
import 'package:dartz/dartz.dart';
import 'package:style_cart/core/errors/failures.dart';

part 'cart_notifier.g.dart';

@riverpod
Stream<List<CartItemModel>> cartItems(CartItemsRef ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState is! AuthAuthenticated) {
    return Stream.value([]);
  }
  
  return ref.watch(cartRepositoryProvider).watchCart(authState.user.uid).map((result) {
    return result.fold(
      (failure) => [],
      (items) => items,
    );
  });
}

@riverpod
class CartTotal extends _$CartTotal {
  @override
  Map<String, double> build() {
    final items = ref.watch(cartItemsProvider).value ?? [];
    
    double subtotal = 0;
    double discount = 0;
    
    for (final item in items) {
      subtotal += item.unitPrice * item.quantity;
      discount += (item.unitPrice - item.finalPrice) * item.quantity;
    }
    
    const shipping = 0.0; // Free shipping as per design
    final total = subtotal - discount + shipping;
    
    return {
      'subtotal': subtotal,
      'discount': discount,
      'shipping': shipping,
      'total': total,
    };
  }
}

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  void build() {}

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) return;

    await ref.read(cartRepositoryProvider).updateQuantity(
      userId: authState.user.uid,
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }

  Future<void> removeFromCart(String cartItemId) async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) return;

    await ref.read(cartRepositoryProvider).removeFromCart(
      userId: authState.user.uid,
      cartItemId: cartItemId,
    );
  }

  Future<void> clearCart() async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) return;

    await ref.read(cartRepositoryProvider).clearCart(authState.user.uid);
  }
}
