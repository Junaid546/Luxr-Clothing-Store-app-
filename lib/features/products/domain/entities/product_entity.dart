// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering, sort_constructors_first, avoid_positional_boolean_parameters

import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String productId;
  final String name;
  final String brand;
  final String description;
  final String category;
  final String? subcategory;
  final List<String> tags;
  final double price;
  final int discountPct;
  final double finalPrice;
  final List<String> imageUrls;
  final String thumbnailUrl;
  final Map<String, int> inventory; // size â†’ qty
  final int totalStock;
  final int lowStockThreshold;
  final List<ProductColorEntity> colors;
  final bool isActive;
  final bool isFeatured;
  final bool isNewArrival;
  final bool isLimitedEdition;
  final double avgRating;
  final int reviewCount;
  final int soldCount;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const ProductEntity({
    required this.productId,
    required this.name,
    required this.brand,
    required this.description,
    required this.category,
    this.subcategory,
    required this.tags,
    required this.price,
    required this.discountPct,
    required this.finalPrice,
    required this.imageUrls,
    required this.thumbnailUrl,
    required this.inventory,
    required this.totalStock,
    required this.lowStockThreshold,
    required this.colors,
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
  });

  // â”€â”€ Business logic (pure, no Firebase) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  StockStatus get stockStatus {
    if (totalStock == 0) return StockStatus.outOfStock;
    if (totalStock <= lowStockThreshold) return StockStatus.low;
    return StockStatus.inStock;
  }

  bool isSizeAvailable(String size) => (inventory[size] ?? 0) > 0;

  int stockForSize(String size) => inventory[size] ?? 0;

  bool get hasDiscount => discountPct > 0;

  double get discountAmount => price - finalPrice;

  double get savingsPercent => discountPct.toDouble();

  bool get isLowStock => stockStatus == StockStatus.low;

  bool get isOutOfStock => stockStatus == StockStatus.outOfStock;

  // Available sizes (stock > 0)
  List<String> get availableSizes => inventory.entries
      .where((e) => e.value > 0)
      .map((e) => e.key)
      .toList();

  // Total units across all sizes
  int get computedTotalStock =>
      inventory.values.fold(0, (a, b) => a + b);

  @override
  List<Object?> get props => [
    productId, name, brand, price, discountPct,
    inventory, totalStock, isActive,
  ];
}

class ProductColorEntity extends Equatable {
  final String name;
  final String hexCode;
  
  const ProductColorEntity({
    required this.name, 
    required this.hexCode,
  });
  
  @override
  List<Object> get props => [name, hexCode];
}

enum StockStatus { inStock, low, outOfStock }

extension StockStatusX on StockStatus {
  String get label => switch (this) {
    StockStatus.inStock    => 'IN STOCK',
    StockStatus.low        => 'LOW STOCK',
    StockStatus.outOfStock => 'OUT OF STOCK',
  };

  bool get isAvailable => this != StockStatus.outOfStock;

  // Color token name for UI
  String get colorToken => switch (this) {
    StockStatus.inStock    => 'inStock',
    StockStatus.low        => 'lowStock',
    StockStatus.outOfStock => 'outOfStock',
  };
}

