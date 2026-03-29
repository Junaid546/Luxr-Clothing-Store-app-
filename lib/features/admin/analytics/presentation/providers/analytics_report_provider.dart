import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/providers/firebase_providers.dart';
import 'package:style_cart/features/admin/analytics/data/services/analytics_computation_service.dart';
import 'package:style_cart/features/admin/analytics/domain/models/analytics_models.dart';

part 'analytics_report_provider.g.dart';

// ── Selected period state ─────────────────────────────
@riverpod
class AnalyticsPeriodState extends _$AnalyticsPeriodState {
  @override
  String build() => 'weekly';

  void setPeriod(String period) {
    if (state == period) return;
    state = period;
  }
}

// ── Custom date range state ────────────────────────────
@riverpod
class CustomDateRange extends _$CustomDateRange {
  @override
  DateRange? build() => null;

  void setRange(DateRange range) => state = range;
  void clear() => state = null;
}

// ── Latest order date state (used for auto-invalidation) ─────────────────────────
@riverpod
Stream<DateTime?> latestOrderDate(LatestOrderDateRef ref) {
  return ref.watch(firestoreProvider)
      .collection(FirestoreConstants.orders)
      .orderBy('placedAt', descending: true)
      .limit(1)
      .snapshots()
      .map((QuerySnapshot<Map<String, dynamic>> snap) {
        if (snap.docs.isEmpty) return null;
        return (snap.docs.first.data()['placedAt'] as Timestamp?)?.toDate();
      });
}

// ── Main analytics report (auto-recomputes on period change or new order) ────────────────────────────
@riverpod
Future<AnalyticsReport> analyticsReport(
  AnalyticsReportRef ref,
) async {
  final period = ref.watch(analyticsPeriodStateProvider);
  final customRange = ref.watch(customDateRangeProvider);
  
  // Watch latest order date to trigger re-fetch when a new order is placed
  ref.watch(latestOrderDateProvider);

  // Add slight debounce to prevent rapid re-fetches
  await Future<void>.delayed(const Duration(milliseconds: 100));

  return ref
      .read(analyticsComputationServiceProvider)
      .generateReport(
        period,
        customRange: customRange,
      );
}

// ── Comparison metrics (current vs previous) ──────────
@riverpod
Future<List<ComparisonMetric>> comparisonMetrics(
  ComparisonMetricsRef ref,
) async {
  final report = await ref.watch(
    analyticsReportProvider.future,
  );

  return [
    ComparisonMetric(
      label: 'Revenue',
      currentValue: report.revenue.totalRevenue,
      previousValue: report.revenue.previousTotalRevenue,
      isPositiveGood: true,
    ),
    ComparisonMetric(
      label: 'Orders',
      currentValue: report.orders.totalOrders.toDouble(),
      previousValue: report.orders.previousTotalOrders.toDouble(),
      isPositiveGood: true,
    ),
    ComparisonMetric(
      label: 'New Customers',
      currentValue: report.customers.newCustomers.toDouble(),
      previousValue: report.customers.previousNewCustomers.toDouble(),
      isPositiveGood: true,
    ),
    ComparisonMetric(
      label: 'Cancellation Rate',
      currentValue: report.orders.cancellationRate,
      previousValue: report.orders.previousCancellationRate,
      isPositiveGood: false, // lower is better
    ),
    ComparisonMetric(
      label: 'Avg Order Value',
      currentValue: report.revenue.avgOrderValue,
      previousValue: report.revenue.previousAvgOrderValue,
      isPositiveGood: true,
    ),
  ];
}
