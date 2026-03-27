import 'package:riverpod_annotation/riverpod_annotation.dart';
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

// ── Main analytics report (auto-recomputes on period change) ────────────────────────────────────────────
@riverpod
Future<AnalyticsReport> analyticsReport(
  AnalyticsReportRef ref,
) async {
  final period = ref.watch(analyticsPeriodStateProvider);
  final customRange = ref.watch(customDateRangeProvider);

  // Add slight debounce to prevent rapid re-fetches
  await Future<void>.delayed(const Duration(milliseconds: 100));

  return await ref
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
      previousValue: report.revenue.totalRevenue / (1 + report.revenue.revenueGrowthPct / 100),
      isPositiveGood: true,
    ),
    ComparisonMetric(
      label: 'Orders',
      currentValue: report.orders.totalOrders.toDouble(),
      previousValue: report.orders.totalOrders / (1 + report.orders.ordersGrowthPct / 100),
      isPositiveGood: true,
    ),
    ComparisonMetric(
      label: 'New Customers',
      currentValue: report.customers.newCustomers.toDouble(),
      previousValue: report.customers.newCustomers / (1 + report.customers.customersGrowthPct / 100),
      isPositiveGood: true,
    ),
    ComparisonMetric(
      label: 'Cancellation Rate',
      currentValue: report.orders.cancellationRate,
      previousValue: report.orders.cancellationRate * 0.9, // approximated
      isPositiveGood: false, // lower is better
    ),
    ComparisonMetric(
      label: 'Avg Order Value',
      currentValue: report.revenue.avgOrderValue,
      previousValue: report.revenue.avgOrderValue / (1 + report.revenue.revenueGrowthPct / 100),
      isPositiveGood: true,
    ),
  ];
}
