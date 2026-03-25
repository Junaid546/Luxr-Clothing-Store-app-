// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myOrdersNotifierHash() => r'fe45c9a22328ec494792d40afbc9c793e4da8632';

/// See also [MyOrdersNotifier].
@ProviderFor(MyOrdersNotifier)
final myOrdersNotifierProvider =
    AutoDisposeNotifierProvider<MyOrdersNotifier, MyOrdersState>.internal(
      MyOrdersNotifier.new,
      name: r'myOrdersNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myOrdersNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MyOrdersNotifier = AutoDisposeNotifier<MyOrdersState>;
String _$orderTrackingNotifierHash() =>
    r'44c2d0544481968da1457209b8b060a6b32155e9';

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

abstract class _$OrderTrackingNotifier
    extends BuildlessAutoDisposeNotifier<AsyncValue<OrderEntity>> {
  late final String orderId;

  AsyncValue<OrderEntity> build(String orderId);
}

/// See also [OrderTrackingNotifier].
@ProviderFor(OrderTrackingNotifier)
const orderTrackingNotifierProvider = OrderTrackingNotifierFamily();

/// See also [OrderTrackingNotifier].
class OrderTrackingNotifierFamily extends Family<AsyncValue<OrderEntity>> {
  /// See also [OrderTrackingNotifier].
  const OrderTrackingNotifierFamily();

  /// See also [OrderTrackingNotifier].
  OrderTrackingNotifierProvider call(String orderId) {
    return OrderTrackingNotifierProvider(orderId);
  }

  @override
  OrderTrackingNotifierProvider getProviderOverride(
    covariant OrderTrackingNotifierProvider provider,
  ) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderTrackingNotifierProvider';
}

/// See also [OrderTrackingNotifier].
class OrderTrackingNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          OrderTrackingNotifier,
          AsyncValue<OrderEntity>
        > {
  /// See also [OrderTrackingNotifier].
  OrderTrackingNotifierProvider(String orderId)
    : this._internal(
        () => OrderTrackingNotifier()..orderId = orderId,
        from: orderTrackingNotifierProvider,
        name: r'orderTrackingNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderTrackingNotifierHash,
        dependencies: OrderTrackingNotifierFamily._dependencies,
        allTransitiveDependencies:
            OrderTrackingNotifierFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderTrackingNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  AsyncValue<OrderEntity> runNotifierBuild(
    covariant OrderTrackingNotifier notifier,
  ) {
    return notifier.build(orderId);
  }

  @override
  Override overrideWith(OrderTrackingNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: OrderTrackingNotifierProvider._internal(
        () => create()..orderId = orderId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    OrderTrackingNotifier,
    AsyncValue<OrderEntity>
  >
  createElement() {
    return _OrderTrackingNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderTrackingNotifierProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderTrackingNotifierRef
    on AutoDisposeNotifierProviderRef<AsyncValue<OrderEntity>> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderTrackingNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          OrderTrackingNotifier,
          AsyncValue<OrderEntity>
        >
    with OrderTrackingNotifierRef {
  _OrderTrackingNotifierProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderTrackingNotifierProvider).orderId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
