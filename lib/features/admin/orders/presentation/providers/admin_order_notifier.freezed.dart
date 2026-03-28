// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_order_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AdminOrderState {
  List<OrderEntity> get orders => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSaving => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;
  String get activeTab => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;

  /// Create a copy of AdminOrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminOrderStateCopyWith<AdminOrderState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminOrderStateCopyWith<$Res> {
  factory $AdminOrderStateCopyWith(
          AdminOrderState value, $Res Function(AdminOrderState) then) =
      _$AdminOrderStateCopyWithImpl<$Res, AdminOrderState>;
  @useResult
  $Res call(
      {List<OrderEntity> orders,
      bool isLoading,
      bool isSaving,
      bool hasError,
      String errorMessage,
      String activeTab,
      String searchQuery});
}

/// @nodoc
class _$AdminOrderStateCopyWithImpl<$Res, $Val extends AdminOrderState>
    implements $AdminOrderStateCopyWith<$Res> {
  _$AdminOrderStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminOrderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orders = null,
    Object? isLoading = null,
    Object? isSaving = null,
    Object? hasError = null,
    Object? errorMessage = null,
    Object? activeTab = null,
    Object? searchQuery = null,
  }) {
    return _then(_value.copyWith(
      orders: null == orders
          ? _value.orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<OrderEntity>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _value.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
      activeTab: null == activeTab
          ? _value.activeTab
          : activeTab // ignore: cast_nullable_to_non_nullable
              as String,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdminOrderStateImplCopyWith<$Res>
    implements $AdminOrderStateCopyWith<$Res> {
  factory _$$AdminOrderStateImplCopyWith(_$AdminOrderStateImpl value,
          $Res Function(_$AdminOrderStateImpl) then) =
      __$$AdminOrderStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<OrderEntity> orders,
      bool isLoading,
      bool isSaving,
      bool hasError,
      String errorMessage,
      String activeTab,
      String searchQuery});
}

/// @nodoc
class __$$AdminOrderStateImplCopyWithImpl<$Res>
    extends _$AdminOrderStateCopyWithImpl<$Res, _$AdminOrderStateImpl>
    implements _$$AdminOrderStateImplCopyWith<$Res> {
  __$$AdminOrderStateImplCopyWithImpl(
      _$AdminOrderStateImpl _value, $Res Function(_$AdminOrderStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdminOrderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orders = null,
    Object? isLoading = null,
    Object? isSaving = null,
    Object? hasError = null,
    Object? errorMessage = null,
    Object? activeTab = null,
    Object? searchQuery = null,
  }) {
    return _then(_$AdminOrderStateImpl(
      orders: null == orders
          ? _value._orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<OrderEntity>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _value.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
      activeTab: null == activeTab
          ? _value.activeTab
          : activeTab // ignore: cast_nullable_to_non_nullable
              as String,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AdminOrderStateImpl implements _AdminOrderState {
  const _$AdminOrderStateImpl(
      {final List<OrderEntity> orders = const [],
      this.isLoading = true,
      this.isSaving = false,
      this.hasError = false,
      this.errorMessage = '',
      this.activeTab = 'all',
      this.searchQuery = ''})
      : _orders = orders;

  final List<OrderEntity> _orders;
  @override
  @JsonKey()
  List<OrderEntity> get orders {
    if (_orders is EqualUnmodifiableListView) return _orders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_orders);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSaving;
  @override
  @JsonKey()
  final bool hasError;
  @override
  @JsonKey()
  final String errorMessage;
  @override
  @JsonKey()
  final String activeTab;
  @override
  @JsonKey()
  final String searchQuery;

  @override
  String toString() {
    return 'AdminOrderState(orders: $orders, isLoading: $isLoading, isSaving: $isSaving, hasError: $hasError, errorMessage: $errorMessage, activeTab: $activeTab, searchQuery: $searchQuery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminOrderStateImpl &&
            const DeepCollectionEquality().equals(other._orders, _orders) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.activeTab, activeTab) ||
                other.activeTab == activeTab) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_orders),
      isLoading,
      isSaving,
      hasError,
      errorMessage,
      activeTab,
      searchQuery);

  /// Create a copy of AdminOrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminOrderStateImplCopyWith<_$AdminOrderStateImpl> get copyWith =>
      __$$AdminOrderStateImplCopyWithImpl<_$AdminOrderStateImpl>(
          this, _$identity);
}

abstract class _AdminOrderState implements AdminOrderState {
  const factory _AdminOrderState(
      {final List<OrderEntity> orders,
      final bool isLoading,
      final bool isSaving,
      final bool hasError,
      final String errorMessage,
      final String activeTab,
      final String searchQuery}) = _$AdminOrderStateImpl;

  @override
  List<OrderEntity> get orders;
  @override
  bool get isLoading;
  @override
  bool get isSaving;
  @override
  bool get hasError;
  @override
  String get errorMessage;
  @override
  String get activeTab;
  @override
  String get searchQuery;

  /// Create a copy of AdminOrderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminOrderStateImplCopyWith<_$AdminOrderStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
