// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductModel {
  String get productId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get brand => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get subcategory => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<String> get searchIndex => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get discountPct => throw _privateConstructorUsedError;
  double get finalPrice => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;
  String get thumbnailUrl => throw _privateConstructorUsedError;
  Map<String, int> get inventory =>
      throw _privateConstructorUsedError; // size → qty
  int get totalStock => throw _privateConstructorUsedError;
  int get lowStockThreshold => throw _privateConstructorUsedError;
  List<ProductColor> get colors => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  bool get isNewArrival => throw _privateConstructorUsedError;
  bool get isLimitedEdition => throw _privateConstructorUsedError;
  double get avgRating => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  int get soldCount => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductModelCopyWith<ProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductModelCopyWith<$Res> {
  factory $ProductModelCopyWith(
    ProductModel value,
    $Res Function(ProductModel) then,
  ) = _$ProductModelCopyWithImpl<$Res, ProductModel>;
  @useResult
  $Res call({
    String productId,
    String name,
    String brand,
    String description,
    String category,
    String? subcategory,
    List<String> tags,
    List<String> searchIndex,
    double price,
    int discountPct,
    double finalPrice,
    List<String> imageUrls,
    String thumbnailUrl,
    Map<String, int> inventory,
    int totalStock,
    int lowStockThreshold,
    List<ProductColor> colors,
    bool isActive,
    bool isFeatured,
    bool isNewArrival,
    bool isLimitedEdition,
    double avgRating,
    int reviewCount,
    int soldCount,
    int viewCount,
    DateTime createdAt,
    DateTime updatedAt,
    String createdBy,
  });
}

/// @nodoc
class _$ProductModelCopyWithImpl<$Res, $Val extends ProductModel>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? name = null,
    Object? brand = null,
    Object? description = null,
    Object? category = null,
    Object? subcategory = freezed,
    Object? tags = null,
    Object? searchIndex = null,
    Object? price = null,
    Object? discountPct = null,
    Object? finalPrice = null,
    Object? imageUrls = null,
    Object? thumbnailUrl = null,
    Object? inventory = null,
    Object? totalStock = null,
    Object? lowStockThreshold = null,
    Object? colors = null,
    Object? isActive = null,
    Object? isFeatured = null,
    Object? isNewArrival = null,
    Object? isLimitedEdition = null,
    Object? avgRating = null,
    Object? reviewCount = null,
    Object? soldCount = null,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = null,
  }) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            brand: null == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            subcategory: freezed == subcategory
                ? _value.subcategory
                : subcategory // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            searchIndex: null == searchIndex
                ? _value.searchIndex
                : searchIndex // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            discountPct: null == discountPct
                ? _value.discountPct
                : discountPct // ignore: cast_nullable_to_non_nullable
                      as int,
            finalPrice: null == finalPrice
                ? _value.finalPrice
                : finalPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            imageUrls: null == imageUrls
                ? _value.imageUrls
                : imageUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            thumbnailUrl: null == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            inventory: null == inventory
                ? _value.inventory
                : inventory // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            totalStock: null == totalStock
                ? _value.totalStock
                : totalStock // ignore: cast_nullable_to_non_nullable
                      as int,
            lowStockThreshold: null == lowStockThreshold
                ? _value.lowStockThreshold
                : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                      as int,
            colors: null == colors
                ? _value.colors
                : colors // ignore: cast_nullable_to_non_nullable
                      as List<ProductColor>,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFeatured: null == isFeatured
                ? _value.isFeatured
                : isFeatured // ignore: cast_nullable_to_non_nullable
                      as bool,
            isNewArrival: null == isNewArrival
                ? _value.isNewArrival
                : isNewArrival // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLimitedEdition: null == isLimitedEdition
                ? _value.isLimitedEdition
                : isLimitedEdition // ignore: cast_nullable_to_non_nullable
                      as bool,
            avgRating: null == avgRating
                ? _value.avgRating
                : avgRating // ignore: cast_nullable_to_non_nullable
                      as double,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            soldCount: null == soldCount
                ? _value.soldCount
                : soldCount // ignore: cast_nullable_to_non_nullable
                      as int,
            viewCount: null == viewCount
                ? _value.viewCount
                : viewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductModelImplCopyWith<$Res>
    implements $ProductModelCopyWith<$Res> {
  factory _$$ProductModelImplCopyWith(
    _$ProductModelImpl value,
    $Res Function(_$ProductModelImpl) then,
  ) = __$$ProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String productId,
    String name,
    String brand,
    String description,
    String category,
    String? subcategory,
    List<String> tags,
    List<String> searchIndex,
    double price,
    int discountPct,
    double finalPrice,
    List<String> imageUrls,
    String thumbnailUrl,
    Map<String, int> inventory,
    int totalStock,
    int lowStockThreshold,
    List<ProductColor> colors,
    bool isActive,
    bool isFeatured,
    bool isNewArrival,
    bool isLimitedEdition,
    double avgRating,
    int reviewCount,
    int soldCount,
    int viewCount,
    DateTime createdAt,
    DateTime updatedAt,
    String createdBy,
  });
}

/// @nodoc
class __$$ProductModelImplCopyWithImpl<$Res>
    extends _$ProductModelCopyWithImpl<$Res, _$ProductModelImpl>
    implements _$$ProductModelImplCopyWith<$Res> {
  __$$ProductModelImplCopyWithImpl(
    _$ProductModelImpl _value,
    $Res Function(_$ProductModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? name = null,
    Object? brand = null,
    Object? description = null,
    Object? category = null,
    Object? subcategory = freezed,
    Object? tags = null,
    Object? searchIndex = null,
    Object? price = null,
    Object? discountPct = null,
    Object? finalPrice = null,
    Object? imageUrls = null,
    Object? thumbnailUrl = null,
    Object? inventory = null,
    Object? totalStock = null,
    Object? lowStockThreshold = null,
    Object? colors = null,
    Object? isActive = null,
    Object? isFeatured = null,
    Object? isNewArrival = null,
    Object? isLimitedEdition = null,
    Object? avgRating = null,
    Object? reviewCount = null,
    Object? soldCount = null,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = null,
  }) {
    return _then(
      _$ProductModelImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        brand: null == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        subcategory: freezed == subcategory
            ? _value.subcategory
            : subcategory // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        searchIndex: null == searchIndex
            ? _value._searchIndex
            : searchIndex // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        discountPct: null == discountPct
            ? _value.discountPct
            : discountPct // ignore: cast_nullable_to_non_nullable
                  as int,
        finalPrice: null == finalPrice
            ? _value.finalPrice
            : finalPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        imageUrls: null == imageUrls
            ? _value._imageUrls
            : imageUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        thumbnailUrl: null == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        inventory: null == inventory
            ? _value._inventory
            : inventory // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        totalStock: null == totalStock
            ? _value.totalStock
            : totalStock // ignore: cast_nullable_to_non_nullable
                  as int,
        lowStockThreshold: null == lowStockThreshold
            ? _value.lowStockThreshold
            : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                  as int,
        colors: null == colors
            ? _value._colors
            : colors // ignore: cast_nullable_to_non_nullable
                  as List<ProductColor>,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFeatured: null == isFeatured
            ? _value.isFeatured
            : isFeatured // ignore: cast_nullable_to_non_nullable
                  as bool,
        isNewArrival: null == isNewArrival
            ? _value.isNewArrival
            : isNewArrival // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLimitedEdition: null == isLimitedEdition
            ? _value.isLimitedEdition
            : isLimitedEdition // ignore: cast_nullable_to_non_nullable
                  as bool,
        avgRating: null == avgRating
            ? _value.avgRating
            : avgRating // ignore: cast_nullable_to_non_nullable
                  as double,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        soldCount: null == soldCount
            ? _value.soldCount
            : soldCount // ignore: cast_nullable_to_non_nullable
                  as int,
        viewCount: null == viewCount
            ? _value.viewCount
            : viewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ProductModelImpl extends _ProductModel {
  const _$ProductModelImpl({
    required this.productId,
    required this.name,
    required this.brand,
    required this.description,
    required this.category,
    this.subcategory,
    required final List<String> tags,
    required final List<String> searchIndex,
    required this.price,
    required this.discountPct,
    required this.finalPrice,
    required final List<String> imageUrls,
    required this.thumbnailUrl,
    required final Map<String, int> inventory,
    required this.totalStock,
    required this.lowStockThreshold,
    required final List<ProductColor> colors,
    required this.isActive,
    required this.isFeatured,
    required this.isNewArrival,
    required this.isLimitedEdition,
    required this.avgRating,
    required this.reviewCount,
    required this.soldCount,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  }) : _tags = tags,
       _searchIndex = searchIndex,
       _imageUrls = imageUrls,
       _inventory = inventory,
       _colors = colors,
       super._();

  @override
  final String productId;
  @override
  final String name;
  @override
  final String brand;
  @override
  final String description;
  @override
  final String category;
  @override
  final String? subcategory;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<String> _searchIndex;
  @override
  List<String> get searchIndex {
    if (_searchIndex is EqualUnmodifiableListView) return _searchIndex;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchIndex);
  }

  @override
  final double price;
  @override
  final int discountPct;
  @override
  final double finalPrice;
  final List<String> _imageUrls;
  @override
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  @override
  final String thumbnailUrl;
  final Map<String, int> _inventory;
  @override
  Map<String, int> get inventory {
    if (_inventory is EqualUnmodifiableMapView) return _inventory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_inventory);
  }

  // size → qty
  @override
  final int totalStock;
  @override
  final int lowStockThreshold;
  final List<ProductColor> _colors;
  @override
  List<ProductColor> get colors {
    if (_colors is EqualUnmodifiableListView) return _colors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_colors);
  }

  @override
  final bool isActive;
  @override
  final bool isFeatured;
  @override
  final bool isNewArrival;
  @override
  final bool isLimitedEdition;
  @override
  final double avgRating;
  @override
  final int reviewCount;
  @override
  final int soldCount;
  @override
  final int viewCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String createdBy;

  @override
  String toString() {
    return 'ProductModel(productId: $productId, name: $name, brand: $brand, description: $description, category: $category, subcategory: $subcategory, tags: $tags, searchIndex: $searchIndex, price: $price, discountPct: $discountPct, finalPrice: $finalPrice, imageUrls: $imageUrls, thumbnailUrl: $thumbnailUrl, inventory: $inventory, totalStock: $totalStock, lowStockThreshold: $lowStockThreshold, colors: $colors, isActive: $isActive, isFeatured: $isFeatured, isNewArrival: $isNewArrival, isLimitedEdition: $isLimitedEdition, avgRating: $avgRating, reviewCount: $reviewCount, soldCount: $soldCount, viewCount: $viewCount, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductModelImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.subcategory, subcategory) ||
                other.subcategory == subcategory) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(
              other._searchIndex,
              _searchIndex,
            ) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.discountPct, discountPct) ||
                other.discountPct == discountPct) &&
            (identical(other.finalPrice, finalPrice) ||
                other.finalPrice == finalPrice) &&
            const DeepCollectionEquality().equals(
              other._imageUrls,
              _imageUrls,
            ) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            const DeepCollectionEquality().equals(
              other._inventory,
              _inventory,
            ) &&
            (identical(other.totalStock, totalStock) ||
                other.totalStock == totalStock) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            const DeepCollectionEquality().equals(other._colors, _colors) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.isNewArrival, isNewArrival) ||
                other.isNewArrival == isNewArrival) &&
            (identical(other.isLimitedEdition, isLimitedEdition) ||
                other.isLimitedEdition == isLimitedEdition) &&
            (identical(other.avgRating, avgRating) ||
                other.avgRating == avgRating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.soldCount, soldCount) ||
                other.soldCount == soldCount) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    productId,
    name,
    brand,
    description,
    category,
    subcategory,
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_searchIndex),
    price,
    discountPct,
    finalPrice,
    const DeepCollectionEquality().hash(_imageUrls),
    thumbnailUrl,
    const DeepCollectionEquality().hash(_inventory),
    totalStock,
    lowStockThreshold,
    const DeepCollectionEquality().hash(_colors),
    isActive,
    isFeatured,
    isNewArrival,
    isLimitedEdition,
    avgRating,
    reviewCount,
    soldCount,
    viewCount,
    createdAt,
    updatedAt,
    createdBy,
  ]);

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      __$$ProductModelImplCopyWithImpl<_$ProductModelImpl>(this, _$identity);
}

abstract class _ProductModel extends ProductModel {
  const factory _ProductModel({
    required final String productId,
    required final String name,
    required final String brand,
    required final String description,
    required final String category,
    final String? subcategory,
    required final List<String> tags,
    required final List<String> searchIndex,
    required final double price,
    required final int discountPct,
    required final double finalPrice,
    required final List<String> imageUrls,
    required final String thumbnailUrl,
    required final Map<String, int> inventory,
    required final int totalStock,
    required final int lowStockThreshold,
    required final List<ProductColor> colors,
    required final bool isActive,
    required final bool isFeatured,
    required final bool isNewArrival,
    required final bool isLimitedEdition,
    required final double avgRating,
    required final int reviewCount,
    required final int soldCount,
    required final int viewCount,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final String createdBy,
  }) = _$ProductModelImpl;
  const _ProductModel._() : super._();

  @override
  String get productId;
  @override
  String get name;
  @override
  String get brand;
  @override
  String get description;
  @override
  String get category;
  @override
  String? get subcategory;
  @override
  List<String> get tags;
  @override
  List<String> get searchIndex;
  @override
  double get price;
  @override
  int get discountPct;
  @override
  double get finalPrice;
  @override
  List<String> get imageUrls;
  @override
  String get thumbnailUrl;
  @override
  Map<String, int> get inventory; // size → qty
  @override
  int get totalStock;
  @override
  int get lowStockThreshold;
  @override
  List<ProductColor> get colors;
  @override
  bool get isActive;
  @override
  bool get isFeatured;
  @override
  bool get isNewArrival;
  @override
  bool get isLimitedEdition;
  @override
  double get avgRating;
  @override
  int get reviewCount;
  @override
  int get soldCount;
  @override
  int get viewCount;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get createdBy;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
