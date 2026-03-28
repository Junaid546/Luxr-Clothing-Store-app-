import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/features/admin/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:style_cart/features/admin/dashboard/domain/models/dashboard_stats_model.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';

part 'dashboard_providers.g.dart';

@riverpod
Future<DashboardStats> dashboardStats(DashboardStatsRef ref) async {
  final period = ref.watch(dashboardPeriodProvider);
  final now = DateTime.now();
  
  DateTime periodStart;
  switch (period) {
    case '30D':
      periodStart = now.subtract(const Duration(days: 30));
      break;
    case '3M':
      periodStart = DateTime(now.year, now.month - 3, now.day);
      break;
    case '1Y':
      periodStart = DateTime(now.year - 1, now.month, now.day);
      break;
    case '7D':
    default:
      periodStart = now.subtract(const Duration(days: 7));
      break;
  }

  final result = await ref.read(dashboardRepositoryProvider).getStats(
        periodStart: periodStart,
        periodEnd: now,
      );
  
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
}

@riverpod
Future<WeeklyRevenueData> weeklyRevenue(WeeklyRevenueRef ref) async {
  final result = await ref.read(dashboardRepositoryProvider).getWeeklyRevenue();
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
}

@riverpod
Future<List<ProductEntity>> topSellingProducts(TopSellingProductsRef ref) async {
  final result = await ref.read(dashboardRepositoryProvider).getTopSellingProducts(limit: 5);
  return result.getOrElse(() => []);
}

@riverpod
Stream<List<ActivityItem>> recentActivity(RecentActivityRef ref) {
  return ref
      .read(dashboardRepositoryProvider)
      .watchRecentActivity(limit: 10)
      .map((result) => result.getOrElse(() => []));
}

@riverpod
Future<int> adminLowStockCount(AdminLowStockCountRef ref) async {
  final result = await ref.read(dashboardRepositoryProvider).getLowStockCount();
  return result.getOrElse(() => 0);
}

@riverpod
class DashboardPeriod extends _$DashboardPeriod {
  @override
  String build() => '7D';

  void setPeriod(String period) {
    state = period;
    ref.invalidate(dashboardStatsProvider);
  }
}
