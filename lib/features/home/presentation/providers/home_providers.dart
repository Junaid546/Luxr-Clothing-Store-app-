// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';
import 'package:style_cart/core/providers/firebase_providers.dart';
import 'package:style_cart/features/home/data/models/banner_model.dart';
import 'package:style_cart/features/products/data/providers/product_data_providers.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';
import 'package:style_cart/features/products/domain/entities/product_filter_entity.dart';
import 'package:style_cart/features/products/domain/usecases/get_products_usecase.dart';

part 'home_providers.g.dart';

// Featured products (max 10)
@riverpod
Future<List<ProductEntity>> featuredProducts(
  FeaturedProductsRef ref,
) async {
  final result = await ref
      .read(getProductsUseCaseProvider)
      .call(const GetProductsParams(
        filter: ProductFilter(
          isFeatured: true,
          pageSize: 10,
        ),
      ));
  return result.fold(
    (f) => throw Exception(f.message),
    (data) => data,
  );
}

// New arrivals (max 10)
@riverpod
Future<List<ProductEntity>> newArrivalProducts(
  NewArrivalProductsRef ref,
) async {
  final result = await ref
      .read(getProductsUseCaseProvider)
      .call(const GetProductsParams(
        filter: ProductFilter(
          isNewArrival: true,
          pageSize: 10,
        ),
      ));
  return result.fold(
    (f) => throw Exception(f.message),
    (data) => data,
  );
}

// Best sellers (sorted by soldCount)
@riverpod
Future<List<ProductEntity>> bestSellerProducts(
  BestSellerProductsRef ref,
) async {
  final result = await ref
      .read(getProductsUseCaseProvider)
      .call(const GetProductsParams(
        filter: ProductFilter(
          sortBy: 'popular',
          pageSize: 6,
        ),
      ));
  return result.fold(
    (f) => throw Exception(f.message),
    (data) => data,
  );
}

// Banners (from Firestore /banners collection)
@riverpod
Future<List<BannerModel>> homeBanners(
  HomeBannersRef ref,
) async {
  final firestore = ref.watch(firestoreProvider);
  try {
    final snap = await firestore
        .collection(FirestoreConstants.banners)
        .orderBy('sortOrder')
        .get();

    return snap.docs
        .map(BannerModel.fromFirestore)
        .where((b) =>
          b.isActive &&
          (b.startDate == null || 
           b.startDate!.isBefore(DateTime.now())) &&
          (b.endDate == null || 
           b.endDate!.isAfter(DateTime.now())),
        )
        .toList();
  } catch (_) {
    return [];
  }
}

// Categories
@riverpod
Future<List<String>> productCategories(
  ProductCategoriesRef ref,
) async {
  // Return static categories from schema
  return ProductCategory.all;
}

// Low stock alert count (for admin badge)
@riverpod
Future<int> lowStockCount(LowStockCountRef ref) async {
  const threshold = 5;
  final result = await ref
      .read(getLowStockProductsUseCaseProvider)
      .call(threshold);
  return result.fold((_) => 0, (products) => products.length);
}
