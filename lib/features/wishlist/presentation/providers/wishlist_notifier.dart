import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/providers/repository_providers.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/wishlist/data/models/wishlist_item_model.dart';

part 'wishlist_notifier.freezed.dart';
part 'wishlist_notifier.g.dart';

@freezed
class WishlistState with _$WishlistState {
  const factory WishlistState({
    @Default([]) List<WishlistItemModel> items,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    @Default('') String errorMessage,
  }) = _WishlistState;
}

@riverpod
class WishlistNotifier extends _$WishlistNotifier {
  StreamSubscription? _subscription;

  @override
  WishlistState build() {
    ref.onDispose(() => _subscription?.cancel());

    final authState = ref.watch(authNotifierProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    
    if (user != null) {
      // Defer stream subscription past the current build phase to avoid assertion errors
      Timer.run(() => _watchWishlist(user.uid));
      return const WishlistState(isLoading: true);
    }
    
    return const WishlistState();
  }

  void _watchWishlist(String userId) {
    _subscription?.cancel();
    _subscription = ref
        .read(wishlistRepositoryProvider)
        .watchWishlist(userId)
        .listen((result) {
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: failure.message,
        ),
        (items) => state = state.copyWith(
          isLoading: false,
          items: items,
        ),
      );
    });
  }

  Future<void> addToWishlist(WishlistItemModel item) async {
    final userId = _getCurrentUserId();
    if (userId == null) return;
    await ref.read(wishlistRepositoryProvider).addToWishlist(userId, item);
  }

  Future<void> removeFromWishlist(String productId) async {
    final userId = _getCurrentUserId();
    if (userId == null) return;
    await ref.read(wishlistRepositoryProvider).removeFromWishlist(userId, productId);
  }

  String? _getCurrentUserId() {
    final authState = ref.read(authNotifierProvider);
    return authState is AuthAuthenticated ? authState.user.uid : null;
  }
}

// Provider to check if a specific product is wishlisted
@riverpod
bool isProductWishlisted(
  IsProductWishlistedRef ref,
  String productId,
) {
  final state = ref.watch(wishlistNotifierProvider);
  return state.items.any((item) => item.productId == productId);
}
