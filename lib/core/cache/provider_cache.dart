import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stylecart/core/constants/firestore_constants.dart';
import 'package:stylecart/core/providers/repository_providers.dart';
import 'package:stylecart/features/products/data/models/product_model.dart';
import 'package:stylecart/features/products/data/providers/product_data_providers.dart'
    hide productRepositoryProvider;
import 'package:stylecart/features/products/domain/entities/product_entity.dart';
import 'package:stylecart/features/products/domain/entities/product_filter_entity.dart';
import 'package:stylecart/features/products/domain/usecases/get_products_usecase.dart';

part 'provider_cache.g.dart';

// ── Cache Duration Constants ──────────────────────────
class CacheDuration {
  CacheDuration._();

  static const Duration categories = Duration(hours: 24);
  static const Duration banners = Duration(hours: 6);
  static const Duration productList = Duration(minutes: 5);
  static const Duration productDetail = Duration(minutes: 2);
  static const Duration topProducts = Duration(minutes: 10);
  static const Duration cartData = Duration.zero;
  static const Duration orderList = Duration.zero;
  static const Duration notifications = Duration.zero;
  static const Duration dashboardStats = Duration(minutes: 15);
  static const Duration analyticsReport = Duration(minutes: 30);
  static const Duration weeklyRevenue = Duration(minutes: 15);
}

// ── Keep-alive providers ─────────────────────────────
@riverpod
Stream<ProductEntity> watchProductCached(
  WatchProductCachedRef ref,
  String productId,
) {
  final link = ref.keepAlive();
  Timer? timer;

  ref.onCancel(() {
    timer = Timer(CacheDuration.productDetail, () {
      link.close();
    });
  });

  ref.onResume(() {
    timer?.cancel();
  });

  ref.onDispose(() {
    timer?.cancel();
  });

  return ref
      .watch(productRepositoryProvider)
      .watchProduct(productId)
      .map<ProductEntity>((result) {
    return result.getOrElse(
      () => throw Exception('Product not found'),
    );
  });
}

@riverpod
Future<List<String>> cachedCategories(CachedCategoriesRef ref) async {
  final link = ref.keepAlive();
  Timer(CacheDuration.categories, link.close);

  // Use a predefined list or fetch from Firestore if categories collection exists
  // For now using the ProductCategory constant assumed from context
  return [
    'T-Shirts',
    'Shirts',
    'Pants',
    'Hoodies',
    'Accessories',
    'Shoes',
    'Limited Edition'
  ];
}

@riverpod
Future<List<ProductModel>> cachedBanners(CachedBannersRef ref) async {
  final link = ref.keepAlive();
  Timer(CacheDuration.banners, link.close);

  final firestore = ref.watch(firestoreProvider);
  try {
    final snap = await firestore
        .collection(FirestoreConstants.banners)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get(const GetOptions(source: Source.serverAndCache));
    return snap.docs.map(ProductModel.fromFirestore).toList();
  } catch (_) {
    return [];
  }
}

@riverpod
Future<List<ProductEntity>> cachedFeaturedProducts(
  CachedFeaturedProductsRef ref,
) async {
  final link = ref.keepAlive();
  Timer(CacheDuration.productList, link.close);

  final result = await ref.read(getProductsUseCaseProvider).call(
        GetProductsParams(
          filter: const ProductFilter(
            isFeatured: true,
            pageSize: 10,
          ),
        ),
      );
  return result.getOrElse(() => []);
}

// ── Memory Cache Service ───────────────────────────────
class ProductMemoryCache {
  static const int _maxSize = 100;
  final _cache = <String, _CacheEntry<ProductEntity>>{};

  void put(String key, ProductEntity value) {
    if (_cache.length >= _maxSize) {
      final oldest = _cache.entries.reduce(
          (a, b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b);
      _cache.remove(oldest.key);
    }
    _cache[key] = _CacheEntry(
      value: value,
      timestamp: DateTime.now(),
    );
  }

  ProductEntity? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (DateTime.now().difference(entry.timestamp) >
        CacheDuration.productDetail) {
      _cache.remove(key);
      return null;
    }

    _cache[key] = _CacheEntry(
      value: entry.value,
      timestamp: DateTime.now(),
    );
    return entry.value;
  }

  bool has(String key) => get(key) != null;
  void invalidate(String key) => _cache.remove(key);
  void clear() => _cache.clear();
  int get size => _cache.length;
}

class _CacheEntry<T> {
  final T value;
  final DateTime timestamp;
  const _CacheEntry({
    required this.value,
    required this.timestamp,
  });
}

@riverpod
ProductMemoryCache productMemoryCache(ProductMemoryCacheRef ref) =>
    ProductMemoryCache();
