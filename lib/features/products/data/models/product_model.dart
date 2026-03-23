import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';

@freezed
class ProductModel with _$ProductModel {
  const ProductModel._(); // needed for custom methods

  const factory ProductModel({
    required String productId,
    required String name,
    required String brand,
    required String description,
    required String category,
    String? subcategory,
    required List<String> tags,
    required List<String> searchIndex,
    required double price,
    required int discountPct,
    required double finalPrice,
    required List<String> imageUrls,
    required String thumbnailUrl,
    required Map<String, int> inventory,  // size → qty
    required int totalStock,
    required int lowStockThreshold,
    required List<ProductColor> colors,
    required bool isActive,
    required bool isFeatured,
    required bool isNewArrival,
    required bool isLimitedEdition,
    required double avgRating,
    required int reviewCount,
    required int soldCount,
    required int viewCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String createdBy,
  }) = _ProductModel;

  // ── Stock status ─────────────────────────────────
  StockStatus get stockStatus {
    if (totalStock == 0) return StockStatus.outOfStock;
    if (totalStock <= lowStockThreshold) return StockStatus.low;
    return StockStatus.inStock;
  }

  bool isSizeAvailable(String size) =>
      (inventory[size] ?? 0) > 0;

  double get discountedPrice =>
      price * (1 - discountPct / 100);

  double get discountAmount => price - discountedPrice;

  bool get hasDiscount => discountPct > 0;

  // ── Firestore Deserialization ─────────────────────
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    // Parse inventory map safely
    final rawInventory = 
        d['inventory'] as Map<String, dynamic>? ?? {};
    final inventory = rawInventory.map(
      (k, v) => MapEntry(k, (v as num).toInt()),
    );

    // Parse colors array
    final rawColors = d['colors'] as List<dynamic>? ?? [];
    final colors = rawColors
        .map((c) => ProductColor.fromMap(
              c as Map<String, dynamic>))
        .toList();

    return ProductModel(
      productId:          doc.id,
      name:               d['name'] as String? ?? '',
      brand:              d['brand'] as String? ?? '',
      description:        d['description'] as String? ?? '',
      category:           d['category'] as String? ?? '',
      subcategory:        d['subcategory'] as String?,
      tags:               List<String>.from(
                            d['tags'] as List? ?? []),
      searchIndex:        List<String>.from(
                            d['searchIndex'] as List? ?? []),
      price:              (d['price'] as num?)?.toDouble() 
                            ?? 0.0,
      discountPct:        (d['discountPct'] as num?)?.toInt() 
                            ?? 0,
      finalPrice:         (d['finalPrice'] as num?)?.toDouble() 
                            ?? 0.0,
      imageUrls:          List<String>.from(
                            d['imageUrls'] as List? ?? []),
      thumbnailUrl:       d['thumbnailUrl'] as String? ?? '',
      inventory:          inventory,
      totalStock:         (d['totalStock'] as num?)?.toInt() 
                            ?? 0,
      lowStockThreshold:  (d['lowStockThreshold'] as num?)
                            ?.toInt() ?? 5,
      colors:             colors,
      isActive:           d['isActive'] as bool? ?? true,
      isFeatured:         d['isFeatured'] as bool? ?? false,
      isNewArrival:       d['isNewArrival'] as bool? ?? false,
      isLimitedEdition:   d['isLimitedEdition'] as bool? 
                            ?? false,
      avgRating:          (d['avgRating'] as num?)?.toDouble() 
                            ?? 0.0,
      reviewCount:        (d['reviewCount'] as num?)?.toInt() 
                            ?? 0,
      soldCount:          (d['soldCount'] as num?)?.toInt() 
                            ?? 0,
      viewCount:          (d['viewCount'] as num?)?.toInt() 
                            ?? 0,
      createdAt:          (d['createdAt'] as Timestamp?)
                            ?.toDate() ?? DateTime.now(),
      updatedAt:          (d['updatedAt'] as Timestamp?)
                            ?.toDate() ?? DateTime.now(),
      createdBy:          d['createdBy'] as String? ?? '',
    );
  }

  // ── Firestore Serialization ───────────────────────
  Map<String, dynamic> toFirestore() {
    // Regenerate searchIndex on every write
    final searchTerms = <String>{};
    for (final word in [name, brand, ...tags]) {
      searchTerms.addAll(word.toLowerCase().split(' '));
    }

    return {
      'productId':         productId,
      'name':              name,
      'brand':             brand,
      'description':       description,
      'category':          category,
      'subcategory':       subcategory,
      'tags':              tags,
      'searchIndex':       searchTerms.toList(),
      'price':             price,
      'discountPct':       discountPct,
      'finalPrice':        price * (1 - discountPct / 100),
      'imageUrls':         imageUrls,
      'thumbnailUrl':      imageUrls.isNotEmpty 
                             ? imageUrls.first : '',
      'inventory':         inventory,
      'totalStock':        inventory.values.fold(
                             0, (a, b) => a + b),
      'lowStockThreshold': lowStockThreshold,
      'colors':            colors.map((c) => c.toMap())
                             .toList(),
      'isActive':          isActive,
      'isFeatured':        isFeatured,
      'isNewArrival':      isNewArrival,
      'isLimitedEdition':  isLimitedEdition,
      'avgRating':         avgRating,
      'reviewCount':       reviewCount,
      'soldCount':         soldCount,
      'viewCount':         viewCount,
      'updatedAt':         FieldValue.serverTimestamp(),
      'createdBy':         createdBy,
      // createdAt is set with serverTimestamp on CREATE only
    };
  }
}

// ── Supporting classes ────────────────────────────────
class ProductColor extends Equatable {
  final String name;
  final String hexCode;
  const ProductColor({required this.name, required this.hexCode});

  factory ProductColor.fromMap(Map<String, dynamic> map) =>
      ProductColor(
        name:    map['name'] as String? ?? '',
        hexCode: map['hexCode'] as String? ?? '#000000',
      );

  Map<String, dynamic> toMap() => {
    'name':    name,
    'hexCode': hexCode,
  };

  @override
  List<Object> get props => [name, hexCode];
}

enum StockStatus { inStock, low, outOfStock }

extension StockStatusExtension on StockStatus {
  String get label => switch (this) {
    StockStatus.inStock     => 'IN STOCK',
    StockStatus.low         => 'LOW STOCK',
    StockStatus.outOfStock  => 'OUT OF STOCK',
  };
  bool get isAvailable => this != StockStatus.outOfStock;
}
