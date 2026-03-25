// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartItemsHash() => r'b003bbdd2200c8f249bda57d79051e1c0e64a5d7';

/// See also [cartItems].
@ProviderFor(cartItems)
final cartItemsProvider =
    AutoDisposeStreamProvider<List<CartItemModel>>.internal(
      cartItems,
      name: r'cartItemsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cartItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartItemsRef = AutoDisposeStreamProviderRef<List<CartItemModel>>;
String _$cartTotalHash() => r'dd06af4d2c5de47098039e324fa52fced919ce04';

/// See also [CartTotal].
@ProviderFor(CartTotal)
final cartTotalProvider =
    AutoDisposeNotifierProvider<CartTotal, CartSummary>.internal(
      CartTotal.new,
      name: r'cartTotalProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cartTotalHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CartTotal = AutoDisposeNotifier<CartSummary>;
String _$cartNotifierHash() => r'1c324a0030092f7d7ad78a795ded2b3597275ab5';

/// See also [CartNotifier].
@ProviderFor(CartNotifier)
final cartNotifierProvider =
    AutoDisposeNotifierProvider<CartNotifier, bool>.internal(
      CartNotifier.new,
      name: r'cartNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cartNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CartNotifier = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
