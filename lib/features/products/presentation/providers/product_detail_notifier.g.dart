// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productDetailNotifierHash() =>
    r'85cc374be8ece5b79884ce1fb0045b8462df73fe';

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

abstract class _$ProductDetailNotifier
    extends BuildlessAutoDisposeNotifier<ProductDetailState> {
  late final String productId;

  ProductDetailState build(String productId);
}

/// See also [ProductDetailNotifier].
@ProviderFor(ProductDetailNotifier)
const productDetailNotifierProvider = ProductDetailNotifierFamily();

/// See also [ProductDetailNotifier].
class ProductDetailNotifierFamily extends Family<ProductDetailState> {
  /// See also [ProductDetailNotifier].
  const ProductDetailNotifierFamily();

  /// See also [ProductDetailNotifier].
  ProductDetailNotifierProvider call(String productId) {
    return ProductDetailNotifierProvider(productId);
  }

  @override
  ProductDetailNotifierProvider getProviderOverride(
    covariant ProductDetailNotifierProvider provider,
  ) {
    return call(provider.productId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productDetailNotifierProvider';
}

/// See also [ProductDetailNotifier].
class ProductDetailNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          ProductDetailNotifier,
          ProductDetailState
        > {
  /// See also [ProductDetailNotifier].
  ProductDetailNotifierProvider(String productId)
    : this._internal(
        () => ProductDetailNotifier()..productId = productId,
        from: productDetailNotifierProvider,
        name: r'productDetailNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$productDetailNotifierHash,
        dependencies: ProductDetailNotifierFamily._dependencies,
        allTransitiveDependencies:
            ProductDetailNotifierFamily._allTransitiveDependencies,
        productId: productId,
      );

  ProductDetailNotifierProvider._internal(
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
  ProductDetailState runNotifierBuild(
    covariant ProductDetailNotifier notifier,
  ) {
    return notifier.build(productId);
  }

  @override
  Override overrideWith(ProductDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductDetailNotifierProvider._internal(
        () => create()..productId = productId,
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
  AutoDisposeNotifierProviderElement<ProductDetailNotifier, ProductDetailState>
  createElement() {
    return _ProductDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailNotifierProvider &&
        other.productId == productId;
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
mixin ProductDetailNotifierRef
    on AutoDisposeNotifierProviderRef<ProductDetailState> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductDetailNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          ProductDetailNotifier,
          ProductDetailState
        >
    with ProductDetailNotifierRef {
  _ProductDetailNotifierProviderElement(super.provider);

  @override
  String get productId => (origin as ProductDetailNotifierProvider).productId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
