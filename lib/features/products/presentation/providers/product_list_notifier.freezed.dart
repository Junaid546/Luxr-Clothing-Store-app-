// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_list_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductListState {
  List<ProductEntity> get products => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;
  ProductFilter get filter => throw _privateConstructorUsedError;
  Object? get lastDocument => throw _privateConstructorUsedError;

  /// Create a copy of ProductListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductListStateCopyWith<ProductListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductListStateCopyWith<$Res> {
  factory $ProductListStateCopyWith(
    ProductListState value,
    $Res Function(ProductListState) then,
  ) = _$ProductListStateCopyWithImpl<$Res, ProductListState>;
  @useResult
  $Res call({
    List<ProductEntity> products,
    bool isLoading,
    bool isLoadingMore,
    bool hasMore,
    bool hasError,
    String errorMessage,
    ProductFilter filter,
    Object? lastDocument,
  });
}

/// @nodoc
class _$ProductListStateCopyWithImpl<$Res, $Val extends ProductListState>
    implements $ProductListStateCopyWith<$Res> {
  _$ProductListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? products = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? hasError = null,
    Object? errorMessage = null,
    Object? filter = null,
    Object? lastDocument = freezed,
  }) {
    return _then(
      _value.copyWith(
            products: null == products
                ? _value.products
                : products // ignore: cast_nullable_to_non_nullable
                      as List<ProductEntity>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingMore: null == isLoadingMore
                ? _value.isLoadingMore
                : isLoadingMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasError: null == hasError
                ? _value.hasError
                : hasError // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: null == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            filter: null == filter
                ? _value.filter
                : filter // ignore: cast_nullable_to_non_nullable
                      as ProductFilter,
            lastDocument: freezed == lastDocument
                ? _value.lastDocument
                : lastDocument,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductListStateImplCopyWith<$Res>
    implements $ProductListStateCopyWith<$Res> {
  factory _$$ProductListStateImplCopyWith(
    _$ProductListStateImpl value,
    $Res Function(_$ProductListStateImpl) then,
  ) = __$$ProductListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ProductEntity> products,
    bool isLoading,
    bool isLoadingMore,
    bool hasMore,
    bool hasError,
    String errorMessage,
    ProductFilter filter,
    Object? lastDocument,
  });
}

/// @nodoc
class __$$ProductListStateImplCopyWithImpl<$Res>
    extends _$ProductListStateCopyWithImpl<$Res, _$ProductListStateImpl>
    implements _$$ProductListStateImplCopyWith<$Res> {
  __$$ProductListStateImplCopyWithImpl(
    _$ProductListStateImpl _value,
    $Res Function(_$ProductListStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? products = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? hasError = null,
    Object? errorMessage = null,
    Object? filter = null,
    Object? lastDocument = freezed,
  }) {
    return _then(
      _$ProductListStateImpl(
        products: null == products
            ? _value._products
            : products // ignore: cast_nullable_to_non_nullable
                  as List<ProductEntity>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingMore: null == isLoadingMore
            ? _value.isLoadingMore
            : isLoadingMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasError: null == hasError
            ? _value.hasError
            : hasError // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: null == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        filter: null == filter
            ? _value.filter
            : filter // ignore: cast_nullable_to_non_nullable
                  as ProductFilter,
        lastDocument: freezed == lastDocument
            ? _value.lastDocument
            : lastDocument,
      ),
    );
  }
}

/// @nodoc

class _$ProductListStateImpl implements _ProductListState {
  const _$ProductListStateImpl({
    final List<ProductEntity> products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.hasError = false,
    this.errorMessage = '',
    this.filter = const ProductFilter(),
    this.lastDocument,
  }) : _products = products;

  final List<ProductEntity> _products;
  @override
  @JsonKey()
  List<ProductEntity> get products {
    if (_products is EqualUnmodifiableListView) return _products;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_products);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final bool hasError;
  @override
  @JsonKey()
  final String errorMessage;
  @override
  @JsonKey()
  final ProductFilter filter;
  @override
  final Object? lastDocument;

  @override
  String toString() {
    return 'ProductListState(products: $products, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasMore: $hasMore, hasError: $hasError, errorMessage: $errorMessage, filter: $filter, lastDocument: $lastDocument)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductListStateImpl &&
            const DeepCollectionEquality().equals(other._products, _products) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            const DeepCollectionEquality().equals(
              other.lastDocument,
              lastDocument,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_products),
    isLoading,
    isLoadingMore,
    hasMore,
    hasError,
    errorMessage,
    filter,
    const DeepCollectionEquality().hash(lastDocument),
  );

  /// Create a copy of ProductListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductListStateImplCopyWith<_$ProductListStateImpl> get copyWith =>
      __$$ProductListStateImplCopyWithImpl<_$ProductListStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ProductListState implements ProductListState {
  const factory _ProductListState({
    final List<ProductEntity> products,
    final bool isLoading,
    final bool isLoadingMore,
    final bool hasMore,
    final bool hasError,
    final String errorMessage,
    final ProductFilter filter,
    final Object? lastDocument,
  }) = _$ProductListStateImpl;

  @override
  List<ProductEntity> get products;
  @override
  bool get isLoading;
  @override
  bool get isLoadingMore;
  @override
  bool get hasMore;
  @override
  bool get hasError;
  @override
  String get errorMessage;
  @override
  ProductFilter get filter;
  @override
  Object? get lastDocument;

  /// Create a copy of ProductListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductListStateImplCopyWith<_$ProductListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
