// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MyOrdersState {
  List<OrderEntity> get orders => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;
  String get activeFilter => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  Object? get lastDocument => throw _privateConstructorUsedError;

  /// Create a copy of MyOrdersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyOrdersStateCopyWith<MyOrdersState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyOrdersStateCopyWith<$Res> {
  factory $MyOrdersStateCopyWith(
    MyOrdersState value,
    $Res Function(MyOrdersState) then,
  ) = _$MyOrdersStateCopyWithImpl<$Res, MyOrdersState>;
  @useResult
  $Res call({
    List<OrderEntity> orders,
    bool isLoading,
    bool isLoadingMore,
    bool hasError,
    String errorMessage,
    String activeFilter,
    bool hasMore,
    Object? lastDocument,
  });
}

/// @nodoc
class _$MyOrdersStateCopyWithImpl<$Res, $Val extends MyOrdersState>
    implements $MyOrdersStateCopyWith<$Res> {
  _$MyOrdersStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyOrdersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orders = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasError = null,
    Object? errorMessage = null,
    Object? activeFilter = null,
    Object? hasMore = null,
    Object? lastDocument = freezed,
  }) {
    return _then(
      _value.copyWith(
            orders: null == orders
                ? _value.orders
                : orders // ignore: cast_nullable_to_non_nullable
                      as List<OrderEntity>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingMore: null == isLoadingMore
                ? _value.isLoadingMore
                : isLoadingMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasError: null == hasError
                ? _value.hasError
                : hasError // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: null == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            activeFilter: null == activeFilter
                ? _value.activeFilter
                : activeFilter // ignore: cast_nullable_to_non_nullable
                      as String,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastDocument: freezed == lastDocument
                ? _value.lastDocument
                : lastDocument,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MyOrdersStateImplCopyWith<$Res>
    implements $MyOrdersStateCopyWith<$Res> {
  factory _$$MyOrdersStateImplCopyWith(
    _$MyOrdersStateImpl value,
    $Res Function(_$MyOrdersStateImpl) then,
  ) = __$$MyOrdersStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<OrderEntity> orders,
    bool isLoading,
    bool isLoadingMore,
    bool hasError,
    String errorMessage,
    String activeFilter,
    bool hasMore,
    Object? lastDocument,
  });
}

/// @nodoc
class __$$MyOrdersStateImplCopyWithImpl<$Res>
    extends _$MyOrdersStateCopyWithImpl<$Res, _$MyOrdersStateImpl>
    implements _$$MyOrdersStateImplCopyWith<$Res> {
  __$$MyOrdersStateImplCopyWithImpl(
    _$MyOrdersStateImpl _value,
    $Res Function(_$MyOrdersStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MyOrdersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orders = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasError = null,
    Object? errorMessage = null,
    Object? activeFilter = null,
    Object? hasMore = null,
    Object? lastDocument = freezed,
  }) {
    return _then(
      _$MyOrdersStateImpl(
        orders: null == orders
            ? _value._orders
            : orders // ignore: cast_nullable_to_non_nullable
                  as List<OrderEntity>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingMore: null == isLoadingMore
            ? _value.isLoadingMore
            : isLoadingMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasError: null == hasError
            ? _value.hasError
            : hasError // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: null == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        activeFilter: null == activeFilter
            ? _value.activeFilter
            : activeFilter // ignore: cast_nullable_to_non_nullable
                  as String,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastDocument: freezed == lastDocument
            ? _value.lastDocument
            : lastDocument,
      ),
    );
  }
}

/// @nodoc

class _$MyOrdersStateImpl implements _MyOrdersState {
  const _$MyOrdersStateImpl({
    final List<OrderEntity> orders = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage = '',
    this.activeFilter = 'all',
    this.hasMore = true,
    this.lastDocument,
  }) : _orders = orders;

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
  final bool isLoadingMore;
  @override
  @JsonKey()
  final bool hasError;
  @override
  @JsonKey()
  final String errorMessage;
  @override
  @JsonKey()
  final String activeFilter;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  final Object? lastDocument;

  @override
  String toString() {
    return 'MyOrdersState(orders: $orders, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasError: $hasError, errorMessage: $errorMessage, activeFilter: $activeFilter, hasMore: $hasMore, lastDocument: $lastDocument)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyOrdersStateImpl &&
            const DeepCollectionEquality().equals(other._orders, _orders) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.activeFilter, activeFilter) ||
                other.activeFilter == activeFilter) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            const DeepCollectionEquality().equals(
              other.lastDocument,
              lastDocument,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_orders),
    isLoading,
    isLoadingMore,
    hasError,
    errorMessage,
    activeFilter,
    hasMore,
    const DeepCollectionEquality().hash(lastDocument),
  );

  /// Create a copy of MyOrdersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyOrdersStateImplCopyWith<_$MyOrdersStateImpl> get copyWith =>
      __$$MyOrdersStateImplCopyWithImpl<_$MyOrdersStateImpl>(this, _$identity);
}

abstract class _MyOrdersState implements MyOrdersState {
  const factory _MyOrdersState({
    final List<OrderEntity> orders,
    final bool isLoading,
    final bool isLoadingMore,
    final bool hasError,
    final String errorMessage,
    final String activeFilter,
    final bool hasMore,
    final Object? lastDocument,
  }) = _$MyOrdersStateImpl;

  @override
  List<OrderEntity> get orders;
  @override
  bool get isLoading;
  @override
  bool get isLoadingMore;
  @override
  bool get hasError;
  @override
  String get errorMessage;
  @override
  String get activeFilter;
  @override
  bool get hasMore;
  @override
  Object? get lastDocument;

  /// Create a copy of MyOrdersState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyOrdersStateImplCopyWith<_$MyOrdersStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
