// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering, sort_constructors_first, avoid_positional_boolean_parameters

import 'package:equatable/equatable.dart';

// Encapsulates all filter/sort state for product listing
class ProductFilter extends Equatable {
  final String? category;
  final String sortBy; // 'newest'|'price_asc'|'price_desc'|'rating'|'popular'
  final double? minPrice;
  final double? maxPrice;
  final List<String> sizes; // filter by available sizes
  final bool? isFeatured;
  final bool? isNewArrival;
  final bool? isLimitedEdition;
  final int pageSize;

  const ProductFilter({
    this.category,
    this.sortBy = 'newest',
    this.minPrice,
    this.maxPrice,
    this.sizes = const [],
    this.isFeatured,
    this.isNewArrival,
    this.isLimitedEdition,
    this.pageSize = 20,
  });

  // Returns true if any filter is active
  bool get isFiltered =>
      category != null ||
      minPrice != null ||
      maxPrice != null ||
      sizes.isNotEmpty ||
      isLimitedEdition == true;

  // Count of active filters for badge display
  int get activeFilterCount {
    var count = 0;
    if (category != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (sizes.isNotEmpty) count++;
    if (isLimitedEdition == true) count++;
    return count;
  }

  ProductFilter copyWith({
    String? category,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
    List<String>? sizes,
    bool? isFeatured,
    bool? isNewArrival,
    bool? isLimitedEdition,
    int? pageSize,
  }) =>
      ProductFilter(
        category: category ?? this.category,
        sortBy: sortBy ?? this.sortBy,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        sizes: sizes ?? this.sizes,
        isFeatured: isFeatured ?? this.isFeatured,
        isNewArrival: isNewArrival ?? this.isNewArrival,
        isLimitedEdition: isLimitedEdition ?? this.isLimitedEdition,
        pageSize: pageSize ?? this.pageSize,
      );

  // Reset to defaults
  ProductFilter get cleared => const ProductFilter();

  @override
  List<Object?> get props => [
        category,
        sortBy,
        minPrice,
        maxPrice,
        sizes,
        isFeatured,
        isNewArrival,
        isLimitedEdition,
      ];
}
