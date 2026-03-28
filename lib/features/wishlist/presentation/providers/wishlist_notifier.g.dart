// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isProductWishlistedHash() =>
    r'253a29d42b9ab0d25249c1f1ebb7d9ea1ac00624';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [isProductWishlisted].
@ProviderFor(isProductWishlisted)
const isProductWishlistedProvider = IsProductWishlistedFamily();

/// See also [isProductWishlisted].
class IsProductWishlistedFamily extends Family<bool> {
  /// See also [isProductWishlisted].
  const IsProductWishlistedFamily();

  /// See also [isProductWishlisted].
  IsProductWishlistedProvider call(
    String productId,
  ) {
    return IsProductWishlistedProvider(
      productId,
    );
  }

  @override
  IsProductWishlistedProvider getProviderOverride(
    covariant IsProductWishlistedProvider provider,
  ) {
    return call(
      provider.productId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isProductWishlistedProvider';
}

/// See also [isProductWishlisted].
class IsProductWishlistedProvider extends AutoDisposeProvider<bool> {
  /// See also [isProductWishlisted].
  IsProductWishlistedProvider(
    String productId,
  ) : this._internal(
          (ref) => isProductWishlisted(
            ref as IsProductWishlistedRef,
            productId,
          ),
          from: isProductWishlistedProvider,
          name: r'isProductWishlistedProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isProductWishlistedHash,
          dependencies: IsProductWishlistedFamily._dependencies,
          allTransitiveDependencies:
              IsProductWishlistedFamily._allTransitiveDependencies,
          productId: productId,
        );

  IsProductWishlistedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Override overrideWith(
    bool Function(IsProductWishlistedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsProductWishlistedProvider._internal(
        (ref) => create(ref as IsProductWishlistedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsProductWishlistedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsProductWishlistedProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsProductWishlistedRef on AutoDisposeProviderRef<bool> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _IsProductWishlistedProviderElement
    extends AutoDisposeProviderElement<bool> with IsProductWishlistedRef {
  _IsProductWishlistedProviderElement(super.provider);

  @override
  String get productId => (origin as IsProductWishlistedProvider).productId;
}

String _$wishlistNotifierHash() => r'3241cdf8926ae94246e2bdd8d3655107e5a6dbd3';

/// See also [WishlistNotifier].
@ProviderFor(WishlistNotifier)
final wishlistNotifierProvider =
    AutoDisposeNotifierProvider<WishlistNotifier, WishlistState>.internal(
  WishlistNotifier.new,
  name: r'wishlistNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishlistNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WishlistNotifier = AutoDisposeNotifier<WishlistState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
