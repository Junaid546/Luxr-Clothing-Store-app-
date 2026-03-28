import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:style_cart/app/theme/app_colors.dart';

// ── Core Analytics Report ─────────────────────────────
class AnalyticsReport extends Equatable {
  final String period; // 'today'|'weekly'|...
  final DateRange dateRange;
  final RevenueMetrics revenue;
  final OrderMetrics orders;
  final CustomerMetrics customers;
  final ProductMetrics products;
  final List<TimeSeriesPoint> revenueSeries;
  final List<TimeSeriesPoint> orderSeries;
  final Map<String, CategoryMetric> categoryBreakdown;
  final List<TopProduct> topProducts;
  final List<TopCustomer> topCustomers;
  final DateTime generatedAt;

  const AnalyticsReport({
    required this.period,
    required this.dateRange,
    required this.revenue,
    required this.orders,
    required this.customers,
    required this.products,
    required this.revenueSeries,
    required this.orderSeries,
    required this.categoryBreakdown,
    required this.topProducts,
    required this.topCustomers,
    required this.generatedAt,
  });

  static AnalyticsReport empty(String period) => AnalyticsReport(
        period: period,
        dateRange: DateRange.forPeriod(period),
        revenue: RevenueMetrics.zero,
        orders: OrderMetrics.zero,
        customers: CustomerMetrics.zero,
        products: ProductMetrics.zero,
        revenueSeries: const [],
        orderSeries: const [],
        categoryBreakdown: const {},
        topProducts: const [],
        topCustomers: const [],
        generatedAt: DateTime.now(),
      );

  @override
  List<Object> get props => [period, generatedAt];
}

// ── Date Range ────────────────────────────────────────
class DateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  factory DateRange.forPeriod(String period) {
    final now = DateTime.now();
    final todayStart = DateTime(
      now.year,
      now.month,
      now.day,
    );
    return switch (period) {
      'today' => DateRange(
          start: todayStart,
          end: now,
        ),
      'weekly' => DateRange(
          start: todayStart.subtract(
            const Duration(days: 6),
          ),
          end: now,
        ),
      'monthly' => DateRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        ),
      'yearly' => DateRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        ),
      _ => DateRange(start: todayStart, end: now),
    };
  }

  // Previous period (same duration, before start)
  DateRange get previousPeriod {
    final duration = end.difference(start);
    return DateRange(
      start: start.subtract(duration),
      end: start,
    );
  }

  int get daysCount => end.difference(start).inDays + 1;

  String get displayLabel {
    final fmt = DateFormat('MMM dd, yyyy');
    return '${fmt.format(start)} – ${fmt.format(end)}';
  }

  @override
  List<Object> get props => [start, end];
}

// ── Revenue Metrics ───────────────────────────────────
class RevenueMetrics extends Equatable {
  final double totalRevenue; // delivered orders total
  final double grossRevenue; // sum of subtotals
  final double netRevenue; // gross - discounts
  final double discountGiven; // sum of discountAmount
  final double shippingRevenue; // sum of shippingCost
  final double avgOrderValue; // totalRevenue / orderCount
  final double revenueGrowthPct; // vs previous period
  final double projectedMonthly; // extrapolated
  final double previousTotalRevenue;
  final double previousAvgOrderValue;

  const RevenueMetrics({
    required this.totalRevenue,
    required this.grossRevenue,
    required this.netRevenue,
    required this.discountGiven,
    required this.shippingRevenue,
    required this.avgOrderValue,
    required this.revenueGrowthPct,
    required this.projectedMonthly,
    required this.previousTotalRevenue,
    required this.previousAvgOrderValue,
  });

  static const RevenueMetrics zero = RevenueMetrics(
    totalRevenue: 0,
    grossRevenue: 0,
    netRevenue: 0,
    discountGiven: 0,
    shippingRevenue: 0,
    avgOrderValue: 0,
    revenueGrowthPct: 0,
    projectedMonthly: 0,
    previousTotalRevenue: 0,
    previousAvgOrderValue: 0,
  );

  bool get isGrowthPositive => revenueGrowthPct >= 0;

  String get formattedGrowth =>
      '${isGrowthPositive ? '+' : ''}'
      '${revenueGrowthPct.toStringAsFixed(1)}%';

  @override
  List<Object> get props => [
        totalRevenue,
        grossRevenue,
        avgOrderValue,
      ];
}

// ── Order Metrics ─────────────────────────────────────
class OrderMetrics extends Equatable {
  final int totalOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final int returnedOrders;
  final int pendingOrders;
  final int processingOrders;
  final double cancellationRate; // cancelled / total × 100
  final double refundRate; // returned / total × 100
  final double fulfillmentRate; // delivered / total × 100
  final int avgDeliveryDays; // avg days to deliver
  final int ordersGrowthPct;
  final int previousTotalOrders;
  final double previousCancellationRate;

  const OrderMetrics({
    required this.totalOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.returnedOrders,
    required this.pendingOrders,
    required this.processingOrders,
    required this.cancellationRate,
    required this.refundRate,
    required this.fulfillmentRate,
    required this.avgDeliveryDays,
    required this.ordersGrowthPct,
    required this.previousTotalOrders,
    required this.previousCancellationRate,
  });

  static const OrderMetrics zero = OrderMetrics(
    totalOrders: 0,
    deliveredOrders: 0,
    cancelledOrders: 0,
    returnedOrders: 0,
    pendingOrders: 0,
    processingOrders: 0,
    cancellationRate: 0,
    refundRate: 0,
    fulfillmentRate: 0,
    avgDeliveryDays: 0,
    ordersGrowthPct: 0,
    previousTotalOrders: 0,
    previousCancellationRate: 0,
  );

  @override
  List<Object> get props => [totalOrders, deliveredOrders];
}

// ── Customer Metrics ──────────────────────────────────
class CustomerMetrics extends Equatable {
  final int totalCustomers;
  final int newCustomers; // in period
  final int returningCustomers; // placed >1 order
  final double repeatPurchaseRate;
  final int bronzeCount;
  final int silverCount;
  final int goldCount;
  final int platinumCount;
  final double avgLifetimeValue; // totalSpent / customer
  final int customersGrowthPct;
  final int previousNewCustomers;

  const CustomerMetrics({
    required this.totalCustomers,
    required this.newCustomers,
    required this.returningCustomers,
    required this.repeatPurchaseRate,
    required this.bronzeCount,
    required this.silverCount,
    required this.goldCount,
    required this.platinumCount,
    required this.avgLifetimeValue,
    required this.customersGrowthPct,
    required this.previousNewCustomers,
  });

  static const CustomerMetrics zero = CustomerMetrics(
    totalCustomers: 0,
    newCustomers: 0,
    returningCustomers: 0,
    repeatPurchaseRate: 0,
    bronzeCount: 0,
    silverCount: 0,
    goldCount: 0,
    platinumCount: 0,
    avgLifetimeValue: 0,
    customersGrowthPct: 0,
    previousNewCustomers: 0,
  );

  @override
  List<Object> get props => [
        totalCustomers,
        newCustomers,
      ];
}

// ── Product Metrics ───────────────────────────────────
class ProductMetrics extends Equatable {
  final int totalActiveProducts;
  final int totalOutOfStock;
  final int totalLowStock;
  final double inventoryValue; // price × totalStock SUM
  final double sellThroughRate; // sold/(sold+stock) × 100
  final int totalUnitsSold; // in period
  final double avgProductRating; // across all products
  final int productsWithNoSales; // soldCount == 0

  const ProductMetrics({
    required this.totalActiveProducts,
    required this.totalOutOfStock,
    required this.totalLowStock,
    required this.inventoryValue,
    required this.sellThroughRate,
    required this.totalUnitsSold,
    required this.avgProductRating,
    required this.productsWithNoSales,
  });

  static const ProductMetrics zero = ProductMetrics(
    totalActiveProducts: 0,
    totalOutOfStock: 0,
    totalLowStock: 0,
    inventoryValue: 0,
    sellThroughRate: 0,
    totalUnitsSold: 0,
    avgProductRating: 0,
    productsWithNoSales: 0,
  );

  @override
  List<Object> get props => [
        totalActiveProducts,
        inventoryValue,
      ];
}

// ── Time Series Point (for charts) ───────────────────
class TimeSeriesPoint extends Equatable {
  final DateTime date;
  final double value;
  final String label; // 'Mon', 'Jan', '01', etc.
  final int count; // secondary metric (order count)

  const TimeSeriesPoint({
    required this.date,
    required this.value,
    required this.label,
    required this.count,
  });

  @override
  List<Object> get props => [date, value];
}

// ── Category Metric ───────────────────────────────────
class CategoryMetric extends Equatable {
  final String category;
  final double revenue;
  final int unitsSold;
  final int productCount;
  final double revenueShare; // percentage of total
  final double growthPct;

  const CategoryMetric({
    required this.category,
    required this.revenue,
    required this.unitsSold,
    required this.productCount,
    required this.revenueShare,
    required this.growthPct,
  });

  @override
  List<Object> get props => [category, revenue];
}

// ── Top Product ───────────────────────────────────────
class TopProduct extends Equatable {
  final String productId;
  final String productName;
  final String brand;
  final String imageUrl;
  final String category;
  final int unitsSold;
  final double revenue;
  final double avgRating;
  final int currentStock;
  final double revenueShare; // % of total revenue

  const TopProduct({
    required this.productId,
    required this.productName,
    required this.brand,
    required this.imageUrl,
    required this.category,
    required this.unitsSold,
    required this.revenue,
    required this.avgRating,
    required this.currentStock,
    required this.revenueShare,
  });

  @override
  List<Object> get props => [productId, unitsSold];
}

// ── Top Customer ──────────────────────────────────────
class TopCustomer extends Equatable {
  final String userId;
  final String displayName;
  final String email;
  final String? photoUrl;
  final int totalOrders;
  final double totalSpent;
  final String eliteStatus;
  final DateTime lastOrderDate;

  const TopCustomer({
    required this.userId,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.totalOrders,
    required this.totalSpent,
    required this.eliteStatus,
    required this.lastOrderDate,
  });

  @override
  List<Object> get props => [userId, totalSpent];
}

// ── Comparison Metric (period-over-period) ────────────
class ComparisonMetric extends Equatable {
  final String label;
  final double currentValue;
  final double previousValue;
  final double changeAmount;
  final double changePct;
  final bool isPositiveGood; // for coloring (revenue: true, cancellation: false)

  const ComparisonMetric({
    required this.label,
    required this.currentValue,
    required this.previousValue,
    required this.isPositiveGood,
  })  : changeAmount = currentValue - previousValue,
        changePct = previousValue == 0
            ? (currentValue > 0 ? 100.0 : 0.0)
            : ((currentValue - previousValue) / previousValue * 100);

  bool get isImprovement => isPositiveGood ? changePct >= 0 : changePct <= 0;

  Color get indicatorColor => isImprovement ? AppColors.success : AppColors.error;

  String get formattedChange => '${changePct >= 0 ? '+' : ''}${changePct.toStringAsFixed(1)}%';

  @override
  List<Object> get props => [label, currentValue];
}
