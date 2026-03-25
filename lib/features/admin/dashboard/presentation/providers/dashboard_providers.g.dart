// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardStatsHash() => r'feae0b6854c0f2dbe42d8fd3f5dda5041c4fd442';

/// See also [dashboardStats].
@ProviderFor(dashboardStats)
final dashboardStatsProvider =
    AutoDisposeFutureProvider<DashboardStats>.internal(
      dashboardStats,
      name: r'dashboardStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardStatsRef = AutoDisposeFutureProviderRef<DashboardStats>;
String _$weeklyRevenueHash() => r'2aae3b266f3985b63bf18280211ade08b91f372b';

/// See also [weeklyRevenue].
@ProviderFor(weeklyRevenue)
final weeklyRevenueProvider =
    AutoDisposeFutureProvider<WeeklyRevenueData>.internal(
      weeklyRevenue,
      name: r'weeklyRevenueProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weeklyRevenueHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeeklyRevenueRef = AutoDisposeFutureProviderRef<WeeklyRevenueData>;
String _$topSellingProductsHash() =>
    r'094422c241f0353f296d48de631e6a66b712ad22';

/// See also [topSellingProducts].
@ProviderFor(topSellingProducts)
final topSellingProductsProvider =
    AutoDisposeFutureProvider<List<ProductEntity>>.internal(
      topSellingProducts,
      name: r'topSellingProductsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$topSellingProductsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TopSellingProductsRef =
    AutoDisposeFutureProviderRef<List<ProductEntity>>;
String _$recentActivityHash() => r'd074fd5a652ac95d550c74ab4c7eb25543a2b82b';

/// See also [recentActivity].
@ProviderFor(recentActivity)
final recentActivityProvider =
    AutoDisposeStreamProvider<List<ActivityItem>>.internal(
      recentActivity,
      name: r'recentActivityProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentActivityHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentActivityRef = AutoDisposeStreamProviderRef<List<ActivityItem>>;
String _$adminLowStockCountHash() =>
    r'c79acf7d262e468ae02242a77919b8d1130585a8';

/// See also [adminLowStockCount].
@ProviderFor(adminLowStockCount)
final adminLowStockCountProvider = AutoDisposeFutureProvider<int>.internal(
  adminLowStockCount,
  name: r'adminLowStockCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminLowStockCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminLowStockCountRef = AutoDisposeFutureProviderRef<int>;
String _$dashboardPeriodHash() => r'4b93b6c9b9d7f976a65fe953621ae3dd656b8c7a';

/// See also [DashboardPeriod].
@ProviderFor(DashboardPeriod)
final dashboardPeriodProvider =
    AutoDisposeNotifierProvider<DashboardPeriod, String>.internal(
      DashboardPeriod.new,
      name: r'dashboardPeriodProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardPeriodHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardPeriod = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
