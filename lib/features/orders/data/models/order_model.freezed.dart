// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OrderModel {
  String get orderId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userEmail => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  List<OrderItemModel> get items => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get shippingCost => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;
  double get taxAmount => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  String get shippingMethod => throw _privateConstructorUsedError;
  ShippingAddressModel get shippingAddress =>
      throw _privateConstructorUsedError;
  EstimatedDeliveryModel get estimatedDelivery =>
      throw _privateConstructorUsedError;
  String get paymentMethod => throw _privateConstructorUsedError;
  String get paymentStatus => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<StatusHistoryEntry> get statusHistory =>
      throw _privateConstructorUsedError;
  CourierModel? get courier => throw _privateConstructorUsedError;
  DateTime get placedAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
          OrderModel value, $Res Function(OrderModel) then) =
      _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call(
      {String orderId,
      String userId,
      String userEmail,
      String userName,
      List<OrderItemModel> items,
      double subtotal,
      double shippingCost,
      double discountAmount,
      double taxAmount,
      double total,
      String shippingMethod,
      ShippingAddressModel shippingAddress,
      EstimatedDeliveryModel estimatedDelivery,
      String paymentMethod,
      String paymentStatus,
      String? transactionId,
      String status,
      List<StatusHistoryEntry> statusHistory,
      CourierModel? courier,
      DateTime placedAt,
      DateTime updatedAt,
      DateTime? deliveredAt});
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? userId = null,
    Object? userEmail = null,
    Object? userName = null,
    Object? items = null,
    Object? subtotal = null,
    Object? shippingCost = null,
    Object? discountAmount = null,
    Object? taxAmount = null,
    Object? total = null,
    Object? shippingMethod = null,
    Object? shippingAddress = null,
    Object? estimatedDelivery = null,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? transactionId = freezed,
    Object? status = null,
    Object? statusHistory = null,
    Object? courier = freezed,
    Object? placedAt = null,
    Object? updatedAt = null,
    Object? deliveredAt = freezed,
  }) {
    return _then(_value.copyWith(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userEmail: null == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItemModel>,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      shippingCost: null == shippingCost
          ? _value.shippingCost
          : shippingCost // ignore: cast_nullable_to_non_nullable
              as double,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      taxAmount: null == taxAmount
          ? _value.taxAmount
          : taxAmount // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      shippingMethod: null == shippingMethod
          ? _value.shippingMethod
          : shippingMethod // ignore: cast_nullable_to_non_nullable
              as String,
      shippingAddress: null == shippingAddress
          ? _value.shippingAddress
          : shippingAddress // ignore: cast_nullable_to_non_nullable
              as ShippingAddressModel,
      estimatedDelivery: null == estimatedDelivery
          ? _value.estimatedDelivery
          : estimatedDelivery // ignore: cast_nullable_to_non_nullable
              as EstimatedDeliveryModel,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      statusHistory: null == statusHistory
          ? _value.statusHistory
          : statusHistory // ignore: cast_nullable_to_non_nullable
              as List<StatusHistoryEntry>,
      courier: freezed == courier
          ? _value.courier
          : courier // ignore: cast_nullable_to_non_nullable
              as CourierModel?,
      placedAt: null == placedAt
          ? _value.placedAt
          : placedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
          _$OrderModelImpl value, $Res Function(_$OrderModelImpl) then) =
      __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String orderId,
      String userId,
      String userEmail,
      String userName,
      List<OrderItemModel> items,
      double subtotal,
      double shippingCost,
      double discountAmount,
      double taxAmount,
      double total,
      String shippingMethod,
      ShippingAddressModel shippingAddress,
      EstimatedDeliveryModel estimatedDelivery,
      String paymentMethod,
      String paymentStatus,
      String? transactionId,
      String status,
      List<StatusHistoryEntry> statusHistory,
      CourierModel? courier,
      DateTime placedAt,
      DateTime updatedAt,
      DateTime? deliveredAt});
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
      _$OrderModelImpl _value, $Res Function(_$OrderModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? userId = null,
    Object? userEmail = null,
    Object? userName = null,
    Object? items = null,
    Object? subtotal = null,
    Object? shippingCost = null,
    Object? discountAmount = null,
    Object? taxAmount = null,
    Object? total = null,
    Object? shippingMethod = null,
    Object? shippingAddress = null,
    Object? estimatedDelivery = null,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? transactionId = freezed,
    Object? status = null,
    Object? statusHistory = null,
    Object? courier = freezed,
    Object? placedAt = null,
    Object? updatedAt = null,
    Object? deliveredAt = freezed,
  }) {
    return _then(_$OrderModelImpl(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userEmail: null == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItemModel>,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      shippingCost: null == shippingCost
          ? _value.shippingCost
          : shippingCost // ignore: cast_nullable_to_non_nullable
              as double,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      taxAmount: null == taxAmount
          ? _value.taxAmount
          : taxAmount // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      shippingMethod: null == shippingMethod
          ? _value.shippingMethod
          : shippingMethod // ignore: cast_nullable_to_non_nullable
              as String,
      shippingAddress: null == shippingAddress
          ? _value.shippingAddress
          : shippingAddress // ignore: cast_nullable_to_non_nullable
              as ShippingAddressModel,
      estimatedDelivery: null == estimatedDelivery
          ? _value.estimatedDelivery
          : estimatedDelivery // ignore: cast_nullable_to_non_nullable
              as EstimatedDeliveryModel,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      statusHistory: null == statusHistory
          ? _value._statusHistory
          : statusHistory // ignore: cast_nullable_to_non_nullable
              as List<StatusHistoryEntry>,
      courier: freezed == courier
          ? _value.courier
          : courier // ignore: cast_nullable_to_non_nullable
              as CourierModel?,
      placedAt: null == placedAt
          ? _value.placedAt
          : placedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$OrderModelImpl extends _OrderModel {
  const _$OrderModelImpl(
      {required this.orderId,
      required this.userId,
      required this.userEmail,
      required this.userName,
      required final List<OrderItemModel> items,
      required this.subtotal,
      required this.shippingCost,
      required this.discountAmount,
      required this.taxAmount,
      required this.total,
      required this.shippingMethod,
      required this.shippingAddress,
      required this.estimatedDelivery,
      required this.paymentMethod,
      required this.paymentStatus,
      this.transactionId,
      required this.status,
      required final List<StatusHistoryEntry> statusHistory,
      this.courier,
      required this.placedAt,
      required this.updatedAt,
      this.deliveredAt})
      : _items = items,
        _statusHistory = statusHistory,
        super._();

  @override
  final String orderId;
  @override
  final String userId;
  @override
  final String userEmail;
  @override
  final String userName;
  final List<OrderItemModel> _items;
  @override
  List<OrderItemModel> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final double subtotal;
  @override
  final double shippingCost;
  @override
  final double discountAmount;
  @override
  final double taxAmount;
  @override
  final double total;
  @override
  final String shippingMethod;
  @override
  final ShippingAddressModel shippingAddress;
  @override
  final EstimatedDeliveryModel estimatedDelivery;
  @override
  final String paymentMethod;
  @override
  final String paymentStatus;
  @override
  final String? transactionId;
  @override
  final String status;
  final List<StatusHistoryEntry> _statusHistory;
  @override
  List<StatusHistoryEntry> get statusHistory {
    if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statusHistory);
  }

  @override
  final CourierModel? courier;
  @override
  final DateTime placedAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deliveredAt;

  @override
  String toString() {
    return 'OrderModel(orderId: $orderId, userId: $userId, userEmail: $userEmail, userName: $userName, items: $items, subtotal: $subtotal, shippingCost: $shippingCost, discountAmount: $discountAmount, taxAmount: $taxAmount, total: $total, shippingMethod: $shippingMethod, shippingAddress: $shippingAddress, estimatedDelivery: $estimatedDelivery, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, transactionId: $transactionId, status: $status, statusHistory: $statusHistory, courier: $courier, placedAt: $placedAt, updatedAt: $updatedAt, deliveredAt: $deliveredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.shippingCost, shippingCost) ||
                other.shippingCost == shippingCost) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.taxAmount, taxAmount) ||
                other.taxAmount == taxAmount) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.shippingMethod, shippingMethod) ||
                other.shippingMethod == shippingMethod) &&
            (identical(other.shippingAddress, shippingAddress) ||
                other.shippingAddress == shippingAddress) &&
            (identical(other.estimatedDelivery, estimatedDelivery) ||
                other.estimatedDelivery == estimatedDelivery) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._statusHistory, _statusHistory) &&
            (identical(other.courier, courier) || other.courier == courier) &&
            (identical(other.placedAt, placedAt) ||
                other.placedAt == placedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        orderId,
        userId,
        userEmail,
        userName,
        const DeepCollectionEquality().hash(_items),
        subtotal,
        shippingCost,
        discountAmount,
        taxAmount,
        total,
        shippingMethod,
        shippingAddress,
        estimatedDelivery,
        paymentMethod,
        paymentStatus,
        transactionId,
        status,
        const DeepCollectionEquality().hash(_statusHistory),
        courier,
        placedAt,
        updatedAt,
        deliveredAt
      ]);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);
}

abstract class _OrderModel extends OrderModel {
  const factory _OrderModel(
      {required final String orderId,
      required final String userId,
      required final String userEmail,
      required final String userName,
      required final List<OrderItemModel> items,
      required final double subtotal,
      required final double shippingCost,
      required final double discountAmount,
      required final double taxAmount,
      required final double total,
      required final String shippingMethod,
      required final ShippingAddressModel shippingAddress,
      required final EstimatedDeliveryModel estimatedDelivery,
      required final String paymentMethod,
      required final String paymentStatus,
      final String? transactionId,
      required final String status,
      required final List<StatusHistoryEntry> statusHistory,
      final CourierModel? courier,
      required final DateTime placedAt,
      required final DateTime updatedAt,
      final DateTime? deliveredAt}) = _$OrderModelImpl;
  const _OrderModel._() : super._();

  @override
  String get orderId;
  @override
  String get userId;
  @override
  String get userEmail;
  @override
  String get userName;
  @override
  List<OrderItemModel> get items;
  @override
  double get subtotal;
  @override
  double get shippingCost;
  @override
  double get discountAmount;
  @override
  double get taxAmount;
  @override
  double get total;
  @override
  String get shippingMethod;
  @override
  ShippingAddressModel get shippingAddress;
  @override
  EstimatedDeliveryModel get estimatedDelivery;
  @override
  String get paymentMethod;
  @override
  String get paymentStatus;
  @override
  String? get transactionId;
  @override
  String get status;
  @override
  List<StatusHistoryEntry> get statusHistory;
  @override
  CourierModel? get courier;
  @override
  DateTime get placedAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deliveredAt;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
