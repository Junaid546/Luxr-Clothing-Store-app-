import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/core/utils/extensions.dart';
import 'package:style_cart/features/admin/analytics/domain/models/analytics_models.dart';
import 'package:style_cart/features/admin/analytics/presentation/providers/analytics_report_provider.dart';
import 'package:style_cart/features/admin/analytics/presentation/widgets/chart_painters.dart';
import 'package:style_cart/features/admin/analytics/presentation/widgets/export_bottom_sheet.dart';
import 'package:style_cart/features/admin/core/providers/admin_guard_provider.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final guardStatus = ref.watch(adminGuardProvider);

    return guardStatus.when(
      data: (isAdmin) {
        if (!isAdmin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(RouteNames.home);
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildAnalyticsContent();
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    final reportAsync = ref.watch(analyticsReportProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
            child: _AnalyticsAppBar(
              currentReport: reportAsync.valueOrNull,
            ),
          ),
          const SliverToBoxAdapter(child: _PeriodSelectorRow()),
          reportAsync.when(
            data: (report) => SliverList(
              delegate: SliverChildListDelegate([
                _RevenueHeroCard(report: report),
                _KPISummaryGrid(report: report),
                _RevenueChartSection(report: report),
                _OrdersChartSection(report: report),
                _CategoryDonutSection(report: report),
                _CustomerInsightsSection(report: report),
                _ProductPerformanceSection(report: report),
                _TopProductsSection(report: report),
                _TopCustomersSection(report: report),
                const _ComparisonTableSection(),
                const SizedBox(height: 32),
              ]),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.analytics_outlined, color: AppColors.gold, size: 64),
                      const SizedBox(height: 24),
                      const Text(
                        'Unable to Load Analytics',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        err.toString().contains('index')
                            ? 'Your database requires composite indexes to run these reports. Please check the log/link below to create them.'
                            : 'An unexpected error occurred while computing metrics.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          err.toString(),
                          style: const TextStyle(color: AppColors.error, fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// APP BAR
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AnalyticsAppBar extends ConsumerWidget {
  /// If non-null, the export button becomes active
  final AnalyticsReport? currentReport;
  const _AnalyticsAppBar({this.currentReport});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ANALYTICS & REPORTS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Text(
                  'Performance Overview',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // Export button (active only when report is loaded)
          if (currentReport != null)
            IconButton(
              tooltip: 'Export Report',
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ExportBottomSheet(report: currentReport!),
              ),
              icon: const Icon(Icons.download_outlined, color: AppColors.gold),
            ),
          IconButton(
            onPressed: () => ref.invalidate(analyticsReportProvider),
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PERIOD SELECTOR
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _PeriodSelectorRow extends ConsumerWidget {
  const _PeriodSelectorRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePeriod = ref.watch(analyticsPeriodStateProvider);
    final customRange = ref.watch(customDateRangeProvider);

    final periods = [
      ('today', 'Today'),
      ('weekly', 'Weekly'),
      ('monthly', 'Monthly'),
      ('yearly', 'Yearly'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ...periods.map((p) {
                    final isActive = activePeriod == p.$1 && customRange == null;
                    return GestureDetector(
                      onTap: () {
                        ref.read(customDateRangeProvider.notifier).clear();
                        ref.read(analyticsPeriodStateProvider.notifier).setPeriod(p.$1);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? AppColors.primary : AppColors.borderDefault,
                          ),
                        ),
                        child: Text(
                          p.$2,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isActive ? Colors.white : AppColors.textMuted,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                  if (customRange != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            customRange.displayLabel,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => ref.read(customDateRangeProvider.notifier).clear(),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.date_range_outlined,
              color: customRange != null ? AppColors.gold : AppColors.textSecondary,
            ),
            onPressed: () => _showDateRangePicker(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context, WidgetRef ref) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold,
            surface: AppColors.backgroundCard,
          ),
        ),
        child: child!,
      ),
    );

    if (range != null) {
      ref.read(customDateRangeProvider.notifier).setRange(DateRange(
            start: range.start,
            end: range.end,
          ));
    }
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REVENUE HERO CARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _RevenueHeroCard extends StatelessWidget {
  final AnalyticsReport report;
  const _RevenueHeroCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundCard,
            Color(0xFF1A0D00), // warm dark
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL REVENUE', style: AppTextStyles.labelSmall),
                  const SizedBox(height: 6),
                  _AnimatedCounter(
                    value: report.revenue.totalRevenue,
                    prefix: '\$',
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: report.revenue.isGrowthPositive ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: report.revenue.isGrowthPositive ? AppColors.success.withOpacity(0.4) : AppColors.error.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      report.revenue.isGrowthPositive ? Icons.trending_up : Icons.trending_down,
                      color: report.revenue.isGrowthPositive ? AppColors.success : AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      report.revenue.formattedGrowth,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: report.revenue.isGrowthPositive ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Projected this month: ${report.revenue.projectedMonthly.toCurrencyString}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 80,
            child: AnimatedChart(
              width: double.infinity,
              height: 80,
              painterBuilder: (anim) => LineChartPainter(
                points: report.revenueSeries,
                lineColor: AppColors.gold,
                showDots: false,
                showGradient: true,
                animationValue: anim,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            report.dateRange.displayLabel,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// KPI GRID
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _KPISummaryGrid extends StatelessWidget {
  final AnalyticsReport report;
  const _KPISummaryGrid({required this.report});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _MiniKPICard(
          label: 'AOV',
          value: report.revenue.avgOrderValue.toCurrencyString,
          change: report.revenue.formattedGrowth,
          isUp: report.revenue.isGrowthPositive,
        ),
        _MiniKPICard(
          label: 'TOTAL ORDERS',
          value: report.orders.totalOrders.toString(),
          change: '${report.orders.ordersGrowthPct}%',
          isUp: report.orders.ordersGrowthPct >= 0,
        ),
        _MiniKPICard(
          label: 'FULFILLMENT',
          value: '${report.orders.fulfillmentRate.toStringAsFixed(1)}%',
          change: 'Target 95%',
          isUp: report.orders.fulfillmentRate >= 95,
        ),
        _MiniKPICard(
          label: 'NEW CLIENTS',
          value: report.customers.newCustomers.toString(),
          change: '${report.customers.customersGrowthPct}%',
          isUp: report.customers.customersGrowthPct >= 0,
        ),
        _MiniKPICard(
          label: 'REPEAT RATE',
          value: '${report.customers.repeatPurchaseRate.toStringAsFixed(1)}%',
          change: 'Avg 22%',
          isUp: report.customers.repeatPurchaseRate >= 22,
        ),
        _MiniKPICard(
          label: 'INVENTORY VAL',
          value: report.products.inventoryValue.toCurrencyString,
          change: 'Stock: ${report.products.totalActiveProducts}',
          isUp: true,
        ),
      ],
    );
  }
}

class _MiniKPICard extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final bool isUp;

  const _MiniKPICard({
    required this.label,
    required this.value,
    required this.change,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmall),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const Spacer(),
          Row(
            children: [
              Icon(
                isUp ? Icons.trending_up : Icons.trending_down,
                size: 12,
                color: isUp ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(fontSize: 10, color: isUp ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REVENUE CHART SECTION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _RevenueChartSection extends StatefulWidget {
  final AnalyticsReport report;
  const _RevenueChartSection({required this.report});

  @override
  State<_RevenueChartSection> createState() => _RevenueChartSectionState();
}

class _RevenueChartSectionState extends State<_RevenueChartSection> {
  bool _showLineChart = true;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Revenue Trend',
      subtitle: widget.report.dateRange.displayLabel,
      actions: [
        Row(
          children: [
            _ChartTypeButton(
              icon: Icons.show_chart,
              isActive: _showLineChart,
              onTap: () => setState(() => _showLineChart = true),
            ),
            const SizedBox(width: 4),
            _ChartTypeButton(
              icon: Icons.bar_chart,
              isActive: !_showLineChart,
              onTap: () => setState(() => _showLineChart = false),
            ),
          ],
        ),
      ],
      chart: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showLineChart
            ? AnimatedChart(
                key: const ValueKey('line'),
                width: double.infinity,
                height: 160,
                painterBuilder: (anim) => LineChartPainter(
                  points: widget.report.revenueSeries,
                  animationValue: anim,
                ),
              )
            : AnimatedChart(
                key: const ValueKey('bar'),
                width: double.infinity,
                height: 160,
                painterBuilder: (anim) => BarChartPainter(
                  points: widget.report.revenueSeries,
                  animationValue: anim,
                ),
              ),
      ),
      xLabels: widget.report.revenueSeries.map((p) => p.label).toList(),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORDERS CHART SECTION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _OrdersChartSection extends StatelessWidget {
  final AnalyticsReport report;
  const _OrdersChartSection({required this.report});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Order Volume',
      subtitle: 'Daily order count',
      chart: AnimatedChart(
        width: double.infinity,
        height: 140,
        painterBuilder: (anim) => BarChartPainter(
          points: report.orderSeries,
          barColor: AppColors.primary,
          animationValue: anim,
        ),
      ),
      xLabels: report.orderSeries.map((p) => p.label).toList(),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CATEGORY DONUT SECTION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _CategoryDonutSection extends StatefulWidget {
  final AnalyticsReport report;
  const _CategoryDonutSection({required this.report});

  @override
  State<_CategoryDonutSection> createState() => _CategoryDonutSectionState();
}

class _CategoryDonutSectionState extends State<_CategoryDonutSection> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final categories = widget.report.categoryBreakdown.values.toList();
    final dataMap = {for (var c in categories) c.category: c.revenue};
    final List<Color> colors = [
      AppColors.gold,
      AppColors.primary,
      AppColors.success,
      Colors.blue,
      Colors.purple,
      Colors.orange,
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CATEGORY MIX', style: AppTextStyles.labelSmall),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: AnimatedChart(
                    width: 180,
                    height: 180,
                    painterBuilder: (anim) => DonutChartPainter(
                      data: dataMap,
                      colors: colors,
                      selectedIndex: _selectedIndex,
                      animationValue: anim,
                      centerLabel: 'TOTAL UNITS',
                      centerValue: widget.report.products.totalUnitsSold.toString(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: Column(
                  children: List.generate(categories.length, (i) {
                    final cat = categories[i];
                    final isSelected = _selectedIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = isSelected ? null : i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colors[i % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cat.category,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              '${cat.revenueShare.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: isSelected ? AppColors.gold : AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          if (_selectedIndex != null) ...[
            const SizedBox(height: 20),
            _CategoryDetailCard(category: categories[_selectedIndex!]),
          ],
        ],
      ),
    );
  }
}

class _CategoryDetailCard extends StatelessWidget {
  final CategoryMetric category;
  const _CategoryDetailCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _DetailItem(label: 'Revenue', value: category.revenue.toCurrencyString),
          _DetailItem(label: 'Units Sold', value: category.unitsSold.toString()),
          _DetailItem(label: 'Products', value: category.productCount.toString()),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CUSTOMER INSIGHTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _CustomerInsightsSection extends StatelessWidget {
  final AnalyticsReport report;
  const _CustomerInsightsSection({required this.report});

  @override
  Widget build(BuildContext context) {
    final c = report.customers;
    final total = c.totalCustomers.toDouble();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CUSTOMER INSIGHTS', style: AppTextStyles.labelSmall),
          const SizedBox(height: 20),
          _StatusRow(label: 'Bronze', count: c.bronzeCount, total: total, color: AppColors.primary),
          _StatusRow(label: 'Silver', count: c.silverCount, total: total, color: Colors.grey),
          _StatusRow(label: 'Gold', count: c.goldCount, total: total, color: AppColors.gold),
          _StatusRow(label: 'Platinum', count: c.platinumCount, total: total, color: Colors.lightBlue),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'REPEAT RATE',
                  value: '${c.repeatPurchaseRate.toStringAsFixed(1)}%',
                ),
              ),
              Expanded(
                child: _MetricTile(
                  label: 'AVG LTV',
                  value: c.avgLifetimeValue.toCurrencyString,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int count;
  final double total;
  final Color color;

  const _StatusRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
              Text('$count customers', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.backgroundElevated,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRODUCT PERFORMANCE (Gauge + Star)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ProductPerformanceSection extends StatelessWidget {
  final AnalyticsReport report;
  const _ProductPerformanceSection({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Column(
                children: [
                  const Text('SELL-THROUGH RATE', style: AppTextStyles.labelSmall),
                  const SizedBox(height: 16),
                  AnimatedChart(
                    width: 140,
                    height: 100,
                    painterBuilder: (anim) => GaugeChartPainter(
                      value: report.products.sellThroughRate,
                      animationValue: anim,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _SummaryMetricTile(
                  label: 'OUT OF STOCK',
                  value: report.products.totalOutOfStock.toString(),
                  color: report.products.totalOutOfStock > 0 ? AppColors.error : AppColors.success,
                ),
                const SizedBox(height: 12),
                _SummaryMetricTile(
                  label: 'AVG RATING',
                  value: report.products.avgProductRating.toStringAsFixed(1),
                  icon: Icons.star,
                  color: AppColors.gold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TOP PRODUCTS SECTION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _TopProductsSection extends StatelessWidget {
  final AnalyticsReport report;
  const _TopProductsSection({required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text('TOP PERFORMANCE PRODUCTS', style: AppTextStyles.labelSmall),
        ),
        ...List.generate(report.topProducts.length, (i) {
          final product = report.topProducts[i];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: i == 0 ? AppColors.gold.withOpacity(0.05) : AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: i == 0 ? AppColors.gold.withOpacity(0.3) : AppColors.borderDefault,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: i == 0 ? AppColors.gold : AppColors.backgroundElevated,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('#${i + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: i == 0 ? Colors.black : AppColors.textMuted,
                            )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        width: 48,
                        height: 52,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: AppColors.backgroundElevated),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.productName,
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(product.category, style: AppTextStyles.labelSmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(product.revenue.toCurrencyString, style: AppTextStyles.titleMedium.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
                        Text('${product.unitsSold} units', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (product.revenueShare / 100).clamp(0.0, 1.0),
                    backgroundColor: AppColors.backgroundElevated,
                    valueColor: AlwaysStoppedAnimation(i == 0 ? AppColors.gold : AppColors.gold.withOpacity(0.5)),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${product.revenueShare.toStringAsFixed(1)}% of revenue', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    if (product.currentStock < 10)
                      Row(
                        children: [
                          const Icon(Icons.warning_amber, size: 12, color: AppColors.warning),
                          const SizedBox(width: 3),
                          Text('${product.currentStock} left', style: const TextStyle(fontSize: 10, color: AppColors.warning)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TOP CUSTOMERS SECTION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _TopCustomersSection extends StatelessWidget {
  final AnalyticsReport report;
  const _TopCustomersSection({required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text('MOST VALUABLE CUSTOMERS', style: AppTextStyles.labelSmall),
        ),
        SizedBox(
          height: 145,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: report.topCustomers.length,
            itemBuilder: (_, i) {
              final customer = report.topCustomers[i];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: i == 0 ? AppColors.gold.withOpacity(0.4) : AppColors.borderDefault,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: customer.photoUrl != null
                          ? CachedNetworkImage(imageUrl: customer.photoUrl!, width: 40, height: 40, fit: BoxFit.cover)
                          : Container(width: 40, height: 40, color: AppColors.backgroundElevated, child: const Icon(Icons.person, color: AppColors.textMuted)),
                    ),
                    const SizedBox(height: 8),
                    Text(customer.displayName.split(' ').first,
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _eliteColor(customer.eliteStatus).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(customer.eliteStatus,
                          style: TextStyle(fontSize: 8, color: _eliteColor(customer.eliteStatus), fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 6),
                    Text(customer.totalSpent.toCurrencyString, style: const TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _eliteColor(String status) => switch (status.toUpperCase()) {
        'PLATINUM' => Colors.lightBlue,
        'GOLD' => AppColors.gold,
        'SILVER' => Colors.grey,
        _ => AppColors.primary,
      };
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COMPARISON TABLE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ComparisonTableSection extends ConsumerWidget {
  const _ComparisonTableSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(comparisonMetricsProvider);

    return metricsAsync.when(
      data: (metrics) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          children: [
            const _ComparisonTableRow(
              label: 'METRIC',
              current: 'CURRENT',
              previous: 'PREV',
              change: 'CHANGE',
              isHeader: true,
            ),
            ...metrics.map((m) => _ComparisonTableRow(
                  label: m.label,
                  current: _formatMetricValue(m.label, m.currentValue),
                  previous: _formatMetricValue(m.label, m.previousValue),
                  change: m.formattedChange,
                  changeColor: m.indicatorColor,
                  isImprovement: m.isImprovement,
                )),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  String _formatMetricValue(String label, double val) {
    if (label.contains('Revenue') || label.contains('Value')) {
      return '\$${val >= 1000 ? '${(val / 1000).toStringAsFixed(1)}k' : val.toStringAsFixed(0)}';
    }
    if (label.contains('Rate')) {
      return '${val.toStringAsFixed(1)}%';
    }
    return val.toInt().toString();
  }
}

class _ComparisonTableRow extends StatelessWidget {
  final String label;
  final String current;
  final String previous;
  final String change;
  final Color? changeColor;
  final bool isImprovement;
  final bool isHeader;

  const _ComparisonTableRow({
    required this.label,
    required this.current,
    required this.previous,
    required this.change,
    this.changeColor,
    this.isImprovement = false,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderDefault,
            width: isHeader ? 1.5 : 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: isHeader ? AppTextStyles.labelSmall : AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
          ),
          Expanded(
            child: Text(current, textAlign: TextAlign.right, style: isHeader ? AppTextStyles.labelSmall : AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
          ),
          Expanded(
            child: Text(previous, textAlign: TextAlign.right, style: isHeader ? AppTextStyles.labelSmall : AppTextStyles.bodySmall),
          ),
          const SizedBox(width: 8),
          Container(
            width: 55,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: isHeader
                ? null
                : BoxDecoration(
                    color: (changeColor ?? Colors.transparent).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
            child: Text(
              change,
              textAlign: TextAlign.center,
              style: isHeader
                  ? AppTextStyles.labelSmall
                  : TextStyle(
                      fontSize: 10,
                      color: changeColor,
                      fontWeight: FontWeight.bold,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUPPORTING WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _AnimatedCounter extends StatefulWidget {
  final double value;
  final String prefix;
  const _AnimatedCounter({
    required this.value,
    this.prefix = '',
  });

  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _oldValue = old.value;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (_, __) {
          final current = _oldValue + (_animation.value * (widget.value - _oldValue));
          return Text(
            '${widget.prefix}${_formatLargeNumber(current)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          );
        },
      );

  String _formatLargeNumber(double v) {
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(2)}M';
    }
    if (v >= 1000) {
      return NumberFormat('#,##0.00').format(v);
    }
    return v.toStringAsFixed(2);
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SummaryMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color color;

  const _SummaryMetricTile({
    required this.label,
    required this.value,
    this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.labelSmall),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
              ],
              Text(value, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget>? actions;
  final Widget chart;
  final List<String> xLabels;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    this.actions,
    required this.chart,
    required this.xLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.toUpperCase(), style: AppTextStyles.labelSmall),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
              if (actions != null) Row(children: actions!),
            ],
          ),
          const SizedBox(height: 24),
          chart,
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildXLabels(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildXLabels() {
    if (xLabels.isEmpty) return [];
    
    // Limits the number of labels to avoid overcrowding
    const maxLabels = 7;
    if (xLabels.length <= maxLabels) {
      return xLabels.map((l) => Text(l, style: const TextStyle(fontSize: 10, color: AppColors.textMuted))).toList();
    }
    
    final result = <Widget>[];
    for (int i = 0; i < xLabels.length; i++) {
        if (i == 0 || i == xLabels.length - 1 || i % (xLabels.length ~/ (maxLabels - 1)) == 0) {
            result.add(Text(xLabels[i], style: const TextStyle(fontSize: 10, color: AppColors.textMuted)));
        }
    }
    return result;
  }
}

class _ChartTypeButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ChartTypeButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold : AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: isActive ? Colors.black : AppColors.textMuted),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
