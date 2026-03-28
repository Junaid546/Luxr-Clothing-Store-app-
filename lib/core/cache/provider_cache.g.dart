// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_cache.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$watchProductCachedHash() =>
    r'c86388f9efff81e1120d9d3f71b71f1e7d8f0154';

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

/// See also [watchProductCached].
@ProviderFor(watchProductCached)
const watchProductCachedProvider = WatchProductCachedFamily();

/// See also [watchProductCached].
class WatchProductCachedFamily extends Family<AsyncValue<ProductEntity>> {
  /// See also [watchProductCached].
  const WatchProductCachedFamily();

  /// See also [watchProductCached].
  WatchProductCachedProvider call(
    String productId,
  ) {
    return WatchProductCachedProvider(
      productId,
    );
  }

  @override
  WatchProductCachedProvider getProviderOverride(
    covariant WatchProductCachedProvider provider,
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
  String? get name => r'watchProductCachedProvider';
}

/// See also [watchProductCached].
class WatchProductCachedProvider
    extends AutoDisposeStreamProvider<ProductEntity> {
  /// See also [watchProductCached].
  WatchProductCachedProvider(
    String productId,
  ) : this._internal(
          (ref) => watchProductCached(
            ref as WatchProductCachedRef,
            productId,
          ),
          from: watchProductCachedProvider,
          name: r'watchProductCachedProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$watchProductCachedHash,
          dependencies: WatchProductCachedFamily._dependencies,
          allTransitiveDependencies:
              WatchProductCachedFamily._allTransitiveDependencies,
          productId: productId,
        );

  WatchProductCachedProvider._internal(
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
    Stream<ProductEntity> Function(WatchProductCachedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchProductCachedProvider._internal(
        (ref) => create(ref as WatchProductCachedRef),
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
  AutoDisposeStreamProviderElement<ProductEntity> createElement() {
    return _WatchProductCachedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchProductCachedProvider && other.productId == productId;
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
mixin WatchProductCachedRef on AutoDisposeStreamProviderRef<ProductEntity> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _WatchProductCachedProviderElement
    extends AutoDisposeStreamProviderElement<ProductEntity>
    with WatchProductCachedRef {
  _WatchProductCachedProviderElement(super.provider);

  @override
  String get productId => (origin as WatchProductCachedProvider).productId;
}

String _$cachedCategoriesHash() => r'b0fbd73abac99c526cb3b4aca37d8db5866df2c4';

/// See also [cachedCategories].
@ProviderFor(cachedCategories)
final cachedCategoriesProvider =
    AutoDisposeFutureProvider<List<String>>.internal(
  cachedCategories,
  name: r'cachedCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cachedCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CachedCategoriesRef = AutoDisposeFutureProviderRef<List<String>>;
String _$cachedBannersHash() => r'fb06efcc2a8abd55db658c4511b6fe03ab21a612';

/// See also [cachedBanners].
@ProviderFor(cachedBanners)
final cachedBannersProvider =
    AutoDisposeFutureProvider<List<ProductModel>>.internal(
  cachedBanners,
  name: r'cachedBannersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cachedBannersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CachedBannersRef = AutoDisposeFutureProviderRef<List<ProductModel>>;
String _$cachedFeaturedProductsHash() =>
    r'246870cc33cd212579379a32f893d1705b4ec5ce';

/// See also [cachedFeaturedProducts].
@ProviderFor(cachedFeaturedProducts)
final cachedFeaturedProductsProvider =
    AutoDisposeFutureProvider<List<ProductEntity>>.internal(
  cachedFeaturedProducts,
  name: r'cachedFeaturedProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cachedFeaturedProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CachedFeaturedProductsRef
    = AutoDisposeFutureProviderRef<List<ProductEntity>>;
String _$productMemoryCacheHash() =>
    r'8ed51e16406c8b908811ad32f5dbbcdc6ac67e10';

/// See also [productMemoryCache].
@ProviderFor(productMemoryCache)
final productMemoryCacheProvider =
    AutoDisposeProvider<ProductMemoryCache>.internal(
  productMemoryCache,
  name: r'productMemoryCacheProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productMemoryCacheHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductMemoryCacheRef = AutoDisposeProviderRef<ProductMemoryCache>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
