import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/core/utils/extensions.dart';
import 'package:style_cart/features/admin/core/providers/admin_guard_provider.dart';
import 'package:style_cart/features/admin/dashboard/domain/models/dashboard_stats_model.dart';
import 'package:style_cart/features/admin/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:style_cart/features/auth/data/providers/auth_providers.dart';
import 'package:style_cart/features/notifications/data/providers/notification_providers.dart';

class AdminDashboardScreen extends ConsumerWidget with AdminGuardMixin {
  const AdminDashboardScreen({super.key});

  @override
  Widget buildAdmin(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _DashboardAppBar()),
          const SliverToBoxAdapter(child: _KPICardsGrid()),
          const SliverToBoxAdapter(child: _WeeklyPerformanceChart()),
          const SliverToBoxAdapter(child: _TopSellingProducts()),
          const SliverToBoxAdapter(child: _RecentActivityFeed()),
          const SliverToBoxAdapter(child: _LowStockAlert()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _DashboardAppBar extends ConsumerWidget {
  const _DashboardAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('LUXR',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                        letterSpacing: 3,
                      )),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.5),
                      ),
                    ),
                    child: const Text('ADMIN',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Welcome back, ${user.displayName}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderDefault,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          Consumer(
            builder: (context, ref, child) {
              final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
              final count = unreadCountAsync.valueOrNull ?? 0;
              
              if (count == 0) return const SizedBox.shrink();
              
              return Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: user.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: user.photoUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.backgroundCard,
                      child: const Icon(Icons.person, color: AppColors.gold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KPICardsGrid extends ConsumerWidget {
  const _KPICardsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      data: (stats) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _KPICard(
            icon: Icons.account_balance_wallet_outlined,
            label: 'TOTAL REVENUE',
            value: stats.totalRevenue.toCurrencyString,
            change: stats.revenueChange,
            isUp: stats.isRevenueUp,
          ),
          _KPICard(
            icon: Icons.shopping_bag_outlined,
            label: 'TOTAL ORDERS',
            value: stats.totalOrders.toString(),
            change: stats.ordersChange,
            isUp: stats.isOrdersUp,
          ),
          _KPICard(
            icon: Icons.people_outline,
            label: 'NEW CLIENTS',
            value: stats.newClients.toString(),
            change: stats.clientsChange,
            isUp: stats.isClientsUp,
          ),
          _KPICard(
            icon: Icons.trending_up,
            label: 'CONVERSION',
            value: '${stats.conversionRate.toStringAsFixed(1)}%',
            change: stats.conversionChange,
            isUp: stats.isConversionUp,
          ),
        ],
      ),
      loading: () => const _KPIShimmerGrid(),
      error: (err, stack) => Center(child: Text(err.toString())),
    );
  }
}

class _KPICard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double change;
  final bool isUp;

  const _KPICard({
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.gold, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isUp
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 10,
                      color: isUp ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${change.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: isUp ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyPerformanceChart extends ConsumerWidget {
  const _WeeklyPerformanceChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklyRevenueProvider);

    return weeklyAsync.when(
      data: (weeklyData) => Container(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('WEEKLY PERFORMANCE',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      weeklyData.total.toCurrencyString,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: ['7D', '30D'].map((period) {
                    final isActive = ref.watch(dashboardPeriodProvider) == period;
                    return GestureDetector(
                      onTap: () =>
                          ref.read(dashboardPeriodProvider.notifier).setPeriod(period),
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.gold
                              : AppColors.backgroundElevated,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          period,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.black : AppColors.textMuted,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 120,
              child: _RevenueLineChart(data: weeklyData),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weeklyData.days
                  .map(
                    (day) => Text(
                      day.dayLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox(height: 200),
      error: (err, stack) => const SizedBox.shrink(),
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
    if (data.days.isEmpty || data.maxRevenue == 0) return;

    final linePaint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.gold.withOpacity(0.3),
          AppColors.gold.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final days = data.days;
    final maxRev = data.maxRevenue;
    final stepX = size.width / (days.length - 1);

    final points = <Offset>[];
    for (int i = 0; i < days.length; i++) {
      final x = i * stepX;
      final normalizedY = maxRev > 0 ? days[i].revenue / maxRev : 0.0;
      final y = size.height - (normalizedY * size.height * 0.85) - size.height * 0.05;
      points.add(Offset(x, y));
    }

    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, gradientPaint);

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final mid = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        (points[i].dy + points[i + 1].dy) / 2,
      );
      linePath.quadraticBezierTo(
        points[i].dx,
        points[i].dy,
        mid.dx,
        mid.dy,
      );
    }
    linePath.lineTo(points.last.dx, points.last.dy);
    canvas.drawPath(linePath, linePaint);

    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = AppColors.backgroundCard
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.data != data;
}

class _TopSellingProducts extends ConsumerWidget {
  const _TopSellingProducts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(topSellingProductsProvider);

    return productsAsync.when(
      data: (products) => products.isEmpty
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text('TOP SELLING',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isFirst = index == 0;
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isFirst ? AppColors.gold : AppColors.borderDefault,
                            width: isFirst ? 1.5 : 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: product.thumbnailUrl,
                                    height: 130,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.finalPrice.toCurrencyString,
                                        style: AppTextStyles.titleMedium.copyWith(
                                          color: AppColors.gold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isFirst
                                      ? AppColors.gold
                                      : AppColors.backgroundCard.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#${index + 1} Rank',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isFirst ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
      loading: () => const SizedBox(height: 200),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _RecentActivityFeed extends ConsumerWidget {
  const _RecentActivityFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider);

    return activityAsync.when(
      data: (activities) => activities.isEmpty
          ? const SizedBox.shrink()
          : Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )),
                      TextButton(
                        onPressed: () => context.go(RouteNames.adminOrders),
                        child: const Text('View All',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...activities
                      .take(5)
                      .map((activity) => _ActivityItemWidget(activity: activity)),
                ],
              ),
            ),
      loading: () => const SizedBox(height: 200),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _ActivityItemWidget extends StatelessWidget {
  final ActivityItem activity;
  const _ActivityItemWidget({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: activity.type == 'order'
                  ? AppColors.primary.withOpacity(0.15)
                  : AppColors.success.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activity.type == 'order'
                  ? Icons.shopping_bag_outlined
                  : Icons.person_add_outlined,
              color: activity.type == 'order' ? AppColors.primary : AppColors.success,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                Text(activity.timeAgo,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (activity.amount != null)
            Text(
              activity.amount!.toCurrencyString,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (activity.amount == null)
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}

class _LowStockAlert extends ConsumerWidget {
  const _LowStockAlert();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(adminLowStockCountProvider);

    return countAsync.when(
      data: (count) => count > 0
          ? GestureDetector(
              onTap: () => context.go(RouteNames.adminProducts),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_outlined,
                        color: AppColors.warning, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$count products low on stock',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Tap to review inventory',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.warning, size: 20),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _KPIShimmerGrid extends StatelessWidget {
  const _KPIShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: List.generate(4, (index) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
        ),
      )),
    );
  }
}
