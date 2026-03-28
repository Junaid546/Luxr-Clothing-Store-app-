import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stylecart/core/constants/firestore_constants.dart';
import 'package:stylecart/core/constants/firestore_schema.dart';
import 'package:stylecart/core/data/firestore_base_repository.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/core/providers/firebase_providers.dart';
import 'package:stylecart/features/admin/dashboard/domain/models/dashboard_stats_model.dart';

part 'analytics_repository_impl.g.dart';

class AnalyticsData extends Equatable {
  final double totalRevenue;
  final double revenueGrowthPct;
  final List<DailyRevenue> revenueTrend;
  final Map<String, double> revenueByCategory;
  final List<BestSellerItem> bestSellers;
  final int totalItemsSold;
  final String selectedPeriod; // 'today'|'weekly'|'monthly'|'yearly'

  const AnalyticsData({
    required this.totalRevenue,
    required this.revenueGrowthPct,
    required this.revenueTrend,
    required this.revenueByCategory,
    required this.bestSellers,
    required this.totalItemsSold,
    required this.selectedPeriod,
  });

  @override
  List<Object> get props =>
      [totalRevenue, selectedPeriod, revenueTrend, bestSellers];
}

class BestSellerItem extends Equatable {
  final String productId;
  final String productName;
  final int unitsSold;
  final double revenue;
  final double progressPct; // relative to top seller

  const BestSellerItem({
    required this.productId,
    required this.productName,
    required this.unitsSold,
    required this.revenue,
    required this.progressPct,
  });

  @override
  List<Object> get props => [productId, unitsSold];
}

abstract interface class AnalyticsRepository {
  Future<Either<Failure, AnalyticsData>> getAnalytics(String period);
}

class AnalyticsRepositoryImpl extends FirestoreBaseRepository
    implements AnalyticsRepository {
  AnalyticsRepositoryImpl(super.firestore);

  @override
  Future<Either<Failure, AnalyticsData>> getAnalytics(String period) {
    return safeFirestoreCall(() async {
      final range = _getDateRange(period);

      // ── Revenue + orders in period ─────────────────
      final ordersSnap = await firestore
          .collection(FirestoreConstants.orders)
          .where('status', isEqualTo: OrderStatus.delivered)
          .where('placedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
          .where('placedAt', isLessThanOrEqualTo: Timestamp.fromDate(range.end))
          .get();

      double totalRevenue = 0;
      final productSales = <String, _ProductSaleData>{};

      for (final doc in ordersSnap.docs) {
        final data = doc.data();
        final orderTotal = (data['total'] as num?)?.toDouble() ?? 0;
        totalRevenue += orderTotal;

        final items = data['items'] as List? ?? [];
        for (final item in items) {
          final map = item as Map<String, dynamic>;
          final lineTotal = (map['lineTotal'] as num?)?.toDouble() ?? 0;
          final qty = (map['quantity'] as num?)?.toInt() ?? 0;
          final productId = map['productId'] as String? ?? '';
          final productName = map['productName'] as String? ?? '';

          if (productId.isNotEmpty) {
            final existing = productSales[productId];
            if (existing != null) {
              productSales[productId] = _ProductSaleData(
                productId: productId,
                productName: productName,
                unitsSold: existing.unitsSold + qty,
                revenue: existing.revenue + lineTotal,
              );
            } else {
              productSales[productId] = _ProductSaleData(
                productId: productId,
                productName: productName,
                unitsSold: qty,
                revenue: lineTotal,
              );
            }
          }
        }
      }

      // ── Revenue by category from products ─────────
      final categoryRevenue = <String, double>{};
      final productsSnap = await firestore
          .collection(FirestoreConstants.products)
          .where('isActive', isEqualTo: true)
          .get();

      for (final doc in productsSnap.docs) {
        final d = doc.data();
        final cat = d['category'] as String? ?? 'Other';
        final sold = (d['soldCount'] as num?)?.toInt() ?? 0;
        final price = (d['finalPrice'] as num?)?.toDouble() ?? 0;
        final catRev = sold * price;
        categoryRevenue[cat] = (categoryRevenue[cat] ?? 0) + catRev;
      }

      // ── Revenue trend ────────────────────────────
      final trend = await _buildRevenueTrend(range, ordersSnap.docs);

      // ── Best sellers ─────────────────────────────
      final sortedProducts = productSales.values.toList()
        ..sort((a, b) => b.unitsSold.compareTo(a.unitsSold));

      final topCount =
          sortedProducts.isNotEmpty ? sortedProducts.first.unitsSold : 1;

      final bestSellers = sortedProducts
          .take(5)
          .map((p) => BestSellerItem(
                productId: p.productId,
                productName: p.productName,
                unitsSold: p.unitsSold,
                revenue: p.revenue,
                progressPct: topCount > 0 ? (p.unitsSold / topCount) * 100 : 0,
              ))
          .toList();

      // ── Revenue growth ───────────────────────────
      final prevRange = _getPreviousRange(period, range);
      final prevSnap = await firestore
          .collection(FirestoreConstants.orders)
          .where('status', isEqualTo: OrderStatus.delivered)
          .where('placedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(prevRange.start))
          .where('placedAt',
              isLessThanOrEqualTo: Timestamp.fromDate(prevRange.end))
          .get();

      double prevRevenue = 0;
      for (final doc in prevSnap.docs) {
        prevRevenue += (doc.data()['total'] as num?)?.toDouble() ?? 0;
      }

      final growthPct = prevRevenue > 0
          ? ((totalRevenue - prevRevenue) / prevRevenue) * 100
          : 0.0;

      return AnalyticsData(
        totalRevenue: totalRevenue,
        revenueGrowthPct: growthPct,
        revenueTrend: trend,
        revenueByCategory: categoryRevenue,
        bestSellers: bestSellers,
        totalItemsSold:
            productSales.values.fold(0, (sum, p) => sum + p.unitsSold),
        selectedPeriod: period,
      );
    });
  }

  ({DateTime start, DateTime end}) _getDateRange(String period) {
    final now = DateTime.now();
    return switch (period) {
      'today' => (
          start: DateTime(now.year, now.month, now.day),
          end: now,
        ),
      'weekly' => (
          start: now.subtract(const Duration(days: 7)),
          end: now,
        ),
      'monthly' => (
          start: DateTime(now.year, now.month, 1),
          end: now,
        ),
      _ => (
          // yearly
          start: DateTime(now.year, 1, 1),
          end: now,
        ),
    };
  }

  ({DateTime start, DateTime end}) _getPreviousRange(
    String period,
    ({DateTime start, DateTime end}) current,
  ) {
    final duration = current.end.difference(current.start);
    return (
      start: current.start.subtract(duration),
      end: current.start,
    );
  }

  Future<List<DailyRevenue>> _buildRevenueTrend(
    ({DateTime start, DateTime end}) range,
    List<QueryDocumentSnapshot> docs,
  ) async {
    final dailyMap = <String, DailyRevenue>{};
    final dayCount = range.end.difference(range.start).inDays.clamp(1, 30);

    for (int i = dayCount; i >= 0; i--) {
      final date = range.end.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      dailyMap[key] = DailyRevenue(
        date: date,
        revenue: 0,
        orderCount: 0,
      );
    }

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final ts = (data['placedAt'] as Timestamp?)?.toDate();
      if (ts == null) continue;
      final key = DateFormat('yyyy-MM-dd').format(ts);
      if (!dailyMap.containsKey(key)) continue;
      final existing = dailyMap[key]!;
      final revenue = (data['total'] as num?)?.toDouble() ?? 0;
      dailyMap[key] = DailyRevenue(
        date: existing.date,
        revenue: existing.revenue + revenue,
        orderCount: existing.orderCount + 1,
      );
    }
    return dailyMap.values.toList();
  }
}

class _ProductSaleData {
  final String productId;
  final String productName;
  final int unitsSold;
  final double revenue;
  const _ProductSaleData({
    required this.productId,
    required this.productName,
    required this.unitsSold,
    required this.revenue,
  });
}

@riverpod
AnalyticsRepository analyticsRepository(AnalyticsRepositoryRef ref) =>
    AnalyticsRepositoryImpl(ref.watch(firestoreProvider));

@riverpod
class AnalyticsPeriod extends _$AnalyticsPeriod {
  @override
  String build() => 'today';

  void setPeriod(String p) {
    state = p;
    ref.invalidate(analyticsDataProvider);
  }
}

@riverpod
Future<AnalyticsData> analyticsData(AnalyticsDataRef ref) async {
  final period = ref.watch(analyticsPeriodProvider);
  final result =
      await ref.read(analyticsRepositoryProvider).getAnalytics(period);
  return result.getOrElse(
    () => AnalyticsData(
      totalRevenue: 0,
      revenueGrowthPct: 0,
      revenueTrend: [],
      revenueByCategory: {},
      bestSellers: [],
      totalItemsSold: 0,
      selectedPeriod: period,
    ),
  );
}
