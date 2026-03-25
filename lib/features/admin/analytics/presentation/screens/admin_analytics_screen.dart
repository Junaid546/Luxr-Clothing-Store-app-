import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/core/utils/extensions.dart';
import 'package:style_cart/features/admin/analytics/data/analytics_repository_impl.dart';
import 'package:style_cart/features/admin/core/providers/admin_guard_provider.dart';
import 'package:style_cart/features/admin/dashboard/domain/models/dashboard_stats_model.dart';

class AdminAnalyticsScreen extends ConsumerWidget with AdminGuardMixin {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget buildAdmin(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _AnalyticsAppBar()),
          const SliverToBoxAdapter(child: _PeriodSelector()),
          const SliverToBoxAdapter(child: _TotalRevenueCard()),
          const SliverToBoxAdapter(child: _CategoryDonutChart()),
          const SliverToBoxAdapter(child: _BestSellersCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _AnalyticsAppBar extends StatelessWidget {
  const _AnalyticsAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          Text('Analytics', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector();

  final _periods = const [
    ('today', 'Today'),
    ('weekly', 'Weekly'),
    ('monthly', 'Monthly'),
    ('yearly', 'Yearly'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPeriod = ref.watch(analyticsPeriodProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: _periods.map((period) {
          final isActive = currentPeriod == period.$1;
          return GestureDetector(
            onTap: () => ref.read(analyticsPeriodProvider.notifier).setPeriod(period.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.borderDefault,
                ),
              ),
              child: Text(
                period.$2,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isActive ? Colors.white : AppColors.textMuted,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TotalRevenueCard extends ConsumerWidget {
  const _TotalRevenueCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsDataProvider);

    return analyticsAsync.when(
      data: (data) => Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL REVENUE',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: data.revenueGrowthPct >= 0
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        data.revenueGrowthPct >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: data.revenueGrowthPct >= 0 ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${data.revenueGrowthPct >= 0 ? '+' : ''}${data.revenueGrowthPct.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: data.revenueGrowthPct >= 0 ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data.totalRevenue.toCurrencyString,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 120,
              child: _RevenueLineChart(data: WeeklyRevenueData(days: data.revenueTrend)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: data.revenueTrend.map((d) {
                final label = DateFormat('dd').format(d.date);
                return Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted));
              }).toList(),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Center(child: Text(err.toString(), style: const TextStyle(color: Colors.white))),
    );
  }
}

class _CategoryDonutChart extends ConsumerWidget {
  const _CategoryDonutChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsDataProvider);

    return analyticsAsync.when(
      data: (data) {
        if (data.revenueByCategory.isEmpty) return const SizedBox.shrink();
        
        final categoryList = data.revenueByCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        final totalValue = data.revenueByCategory.values.fold(0.0, (a, b) => a + b);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SALES BY CATEGORY',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CustomPaint(
                      painter: _DonutChartPainter(
                        data: data.revenueByCategory,
                        totalItems: data.totalItemsSold,
                        colors: const [
                          AppColors.gold,
                          AppColors.primary,
                          AppColors.successTeal,
                          AppColors.warning,
                          Color(0xFF8E44AD),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: categoryList.take(4).map((entry) {
                        final index = categoryList.indexOf(entry);
                        final pct = totalValue > 0 ? (entry.value / totalValue * 100).toInt() : 0;
                        final color = [
                          AppColors.gold,
                          AppColors.primary,
                          AppColors.successTeal,
                          AppColors.warning,
                          const Color(0xFF8E44AD),
                        ][index % 5];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '$pct%',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _BestSellersCard extends ConsumerWidget {
  const _BestSellersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsDataProvider);

    return analyticsAsync.when(
      data: (data) => Container(
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
            const Text('BEST SELLERS',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 20),
            ...data.bestSellers.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item.unitsSold} units',
                            style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (item.progressPct / 100).clamp(0.0, 1.0),
                          backgroundColor: AppColors.backgroundElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            item.progressPct > 80
                                ? AppColors.gold
                                : item.progressPct > 50
                                    ? AppColors.gold.withOpacity(0.8)
                                    : AppColors.primary.withOpacity(0.6),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _RevenueLineChart extends StatelessWidget {
  final WeeklyRevenueData data;
  const _RevenueLineChart({required this.data});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.infinite,
        painter: _LineChartPainter(data: data),
      );
}

class _LineChartPainter extends CustomPainter {
  final WeeklyRevenueData data;
  const _LineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.days.isEmpty) return;
    
    final maxRev = data.maxRevenue == 0 ? 1.0 : data.maxRevenue;

    final linePaint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPath = Path();
    final linePath = Path();
    final stepX = size.width / (data.days.length - 1);

    final points = <Offset>[];
    for (int i = 0; i < data.days.length; i++) {
      final x = i * stepX;
      final y = size.height - (data.days[i].revenue / maxRev * size.height * 0.8);
      points.add(Offset(x, y));
    }

    fillPath.moveTo(0, size.height);
    linePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      linePath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
      fillPath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gold.withOpacity(0.2), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _DonutChartPainter extends CustomPainter {
  final Map<String, double> data;
  final int totalItems;
  final List<Color> colors;

  const _DonutChartPainter({
    required this.data,
    required this.totalItems,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 18.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;

    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    for (int i = 0; i < entries.length; i++) {
      final sweepAngle = (entries[i].value / total) * 2 * pi;
      paint.color = colors[i % colors.length];
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.04,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$totalItems\n',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: 'ITEMS',
            style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(_DonutChartPainter old) => true;
}
