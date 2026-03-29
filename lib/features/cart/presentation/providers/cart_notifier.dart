import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/providers/repository_providers.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/cart/data/models/cart_item_model.dart';
import 'package:style_cart/features/cart/domain/entities/cart_entity.dart';

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
  CartSummary build() {
    final items = ref.watch(cartItemsProvider).value ?? [];
    return CartSummary.compute(items: items);
  }
}

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  bool build() => false; // returns isUpdating state

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity < 1) return;
    state = true;
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) {
      state = false;
      return;
    }

    await ref.read(cartRepositoryProvider).updateQuantity(
      userId: authState.user.uid,
      cartItemId: cartItemId,
      quantity: quantity,
    );
    state = false;
  }

  Future<void> removeFromCart(String cartItemId) async {
    state = true;
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) {
      state = false;
      return;
    }

    await ref.read(cartRepositoryProvider).removeFromCart(
      userId: authState.user.uid,
      cartItemId: cartItemId,
    );
    state = false;
  }

  Future<void> clearCart() async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) return;

    await ref.read(cartRepositoryProvider).clearCart(authState.user.uid);
  }
}
