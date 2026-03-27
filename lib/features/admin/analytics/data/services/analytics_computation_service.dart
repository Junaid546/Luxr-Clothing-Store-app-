import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';
import 'package:style_cart/core/providers/firebase_providers.dart';
import 'package:style_cart/features/admin/analytics/domain/models/analytics_models.dart';

part 'analytics_computation_service.g.dart';

// This service contains ALL calculation logic.
// It reads raw Firestore data and computes every metric.
// NO business logic in the repository — only here.

class AnalyticsComputationService {
  final FirebaseFirestore _firestore;

  const AnalyticsComputationService(this._firestore);

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection(FirestoreConstants.orders);

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection(FirestoreConstants.products);

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(FirestoreConstants.users);

  // ══════════════════════════════════════════════════
  // GENERATE FULL REPORT
  // All computations run in parallel for performance
  // ══════════════════════════════════════════════════
  Future<AnalyticsReport> generateReport(
    String period, {
    DateRange? customRange,
  }) async {
    final range = customRange ?? DateRange.forPeriod(period);
    final prevRange = range.previousPeriod;

    // Run all major data fetches in PARALLEL
    final results = await Future.wait([
      _fetchOrdersInRange(range), // [0] current
      _fetchOrdersInRange(prevRange), // [1] previous
      _fetchAllProducts(), // [2] products
      _fetchCustomerStats(range), // [3] customers
      _fetchPreviousCustomers(prevRange), // [4] prev customers
    ]);

    final currentOrders = results[0] as List<Map<String, dynamic>>;
    final previousOrders = results[1] as List<Map<String, dynamic>>;
    final products = results[2] as List<Map<String, dynamic>>;
    final customerStats = results[3] as _CustomerStatsRaw;
    final prevCustomerStats = results[4] as _CustomerStatsRaw;

    // Compute all metrics
    final revenueMetrics = _computeRevenueMetrics(
      currentOrders,
      previousOrders,
      range,
    );
    final orderMetrics = _computeOrderMetrics(
      currentOrders,
      previousOrders,
    );
    final customerMetrics = _computeCustomerMetrics(
      customerStats,
      prevCustomerStats,
      range,
    );
    final productMetrics = _computeProductMetrics(products);
    final revenueSeries = _buildTimeSeries(
      currentOrders,
      range,
      'revenue',
    );
    final orderSeries = _buildTimeSeries(
      currentOrders,
      range,
      'count',
    );
    final categoryBreakdown = _computeCategoryBreakdown(
      currentOrders,
      products,
    );
    final topProductsList = _computeTopProducts(
      currentOrders,
      products,
    );
    final topCustomersList = await _computeTopCustomers();

    return AnalyticsReport(
      period: period,
      dateRange: range,
      revenue: revenueMetrics,
      orders: orderMetrics,
      customers: customerMetrics,
      products: productMetrics,
      revenueSeries: revenueSeries,
      orderSeries: orderSeries,
      categoryBreakdown: categoryBreakdown,
      topProducts: topProductsList,
      topCustomers: topCustomersList,
      generatedAt: DateTime.now(),
    );
  }

  // ══════════════════════════════════════════════════
  // FETCH ORDERS IN DATE RANGE
  // Returns raw Firestore data maps
  // ══════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> _fetchOrdersInRange(
    DateRange range,
  ) async {
    final snap = await _ordersRef
        .where('placedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
        .where('placedAt', isLessThanOrEqualTo: Timestamp.fromDate(range.end))
        .orderBy('placedAt', descending: false)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      data['__id'] = d.id; // preserve doc ID
      return data;
    }).toList();
  }

  // ══════════════════════════════════════════════════
  // FETCH ALL PRODUCTS (active + inactive for metrics)
  // ══════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> _fetchAllProducts() async {
    final snap = await _productsRef.get();
    return snap.docs.map((d) => d.data()).toList();
  }

  // ══════════════════════════════════════════════════
  // COMPUTE REVENUE METRICS
  // ══════════════════════════════════════════════════
  RevenueMetrics _computeRevenueMetrics(
    List<Map<String, dynamic>> current,
    List<Map<String, dynamic>> previous,
    DateRange range,
  ) {
    // Filter to only DELIVERED orders for revenue
    final delivered = current.where(
      (o) => o['status'] == OrderStatus.delivered,
    ).toList();

    final prevDelivered = previous.where(
      (o) => o['status'] == OrderStatus.delivered,
    ).toList();

    // Compute current period metrics
    double totalRevenue = 0;
    double grossRevenue = 0;
    double discountGiven = 0;
    double shippingRevenue = 0;

    for (final order in delivered) {
      totalRevenue += (order['total'] as num?)?.toDouble() ?? 0;
      grossRevenue += (order['subtotal'] as num?)?.toDouble() ?? 0;
      discountGiven += (order['discountAmount'] as num?)?.toDouble() ?? 0;
      shippingRevenue += (order['shippingCost'] as num?)?.toDouble() ?? 0;
    }

    final netRevenue = grossRevenue - discountGiven;
    final orderCount = delivered.length;
    final avgOrderValue = orderCount > 0 ? totalRevenue / orderCount : 0.0;

    // Compute previous period revenue for growth %
    double prevRevenue = 0;
    for (final order in prevDelivered) {
      prevRevenue += (order['total'] as num?)?.toDouble() ?? 0;
    }

    final growthPct = prevRevenue > 0
        ? ((totalRevenue - prevRevenue) / prevRevenue * 100)
        : (totalRevenue > 0 ? 100.0 : 0.0);

    // Project monthly revenue (extrapolate from current)
    final daysElapsed = range.end.difference(range.start).inDays + 1;
    final dailyRate = daysElapsed > 0 ? totalRevenue / daysElapsed : 0.0;
    final daysInMonth = DateUtils.getDaysInMonth(
      range.start.year,
      range.start.month,
    );
    final projectedMonthly = dailyRate * daysInMonth;

    return RevenueMetrics(
      totalRevenue: totalRevenue,
      grossRevenue: grossRevenue,
      netRevenue: netRevenue,
      discountGiven: discountGiven,
      shippingRevenue: shippingRevenue,
      avgOrderValue: avgOrderValue,
      revenueGrowthPct: growthPct,
      projectedMonthly: projectedMonthly,
    );
  }

  // ══════════════════════════════════════════════════
  // COMPUTE ORDER METRICS
  // ══════════════════════════════════════════════════
  OrderMetrics _computeOrderMetrics(
    List<Map<String, dynamic>> current,
    List<Map<String, dynamic>> previous,
  ) {
    int delivered = 0;
    int cancelled = 0;
    int returned = 0;
    int pending = 0;
    int processing = 0;
    int totalDeliveryDays = 0;
    int deliveredWithDates = 0;

    for (final order in current) {
      final status = order['status'] as String? ?? '';
      switch (status) {
        case OrderStatus.delivered:
          delivered++;
          // Calculate delivery days if both dates exist
          final placedAt = (order['placedAt'] as Timestamp?)?.toDate();
          final deliveredAt = (order['deliveredAt'] as Timestamp?)?.toDate();
          if (placedAt != null && deliveredAt != null) {
            final days = deliveredAt.difference(placedAt).inDays;
            if (days >= 0) {
              totalDeliveryDays += days;
              deliveredWithDates++;
            }
          }
          break;
        case OrderStatus.cancelled:
          cancelled++;
          break;
        case OrderStatus.returned:
          returned++;
          break;
        case OrderStatus.pending:
          pending++;
          break;
        case OrderStatus.processing:
        case OrderStatus.packed:
        case OrderStatus.shipped:
        case OrderStatus.outForDelivery:
          processing++;
          break;
      }
    }

    final total = current.length;
    final safe = total > 0 ? total.toDouble() : 1.0;

    final avgDeliveryDays = deliveredWithDates > 0 ? (totalDeliveryDays / deliveredWithDates).round() : 0;

    // Growth vs previous
    final prevTotal = previous.length;
    final growth = prevTotal > 0 ? ((total - prevTotal) / prevTotal * 100).round() : (total > 0 ? 100 : 0);

    return OrderMetrics(
      totalOrders: total,
      deliveredOrders: delivered,
      cancelledOrders: cancelled,
      returnedOrders: returned,
      pendingOrders: pending,
      processingOrders: processing,
      cancellationRate: cancelled / safe * 100,
      refundRate: returned / safe * 100,
      fulfillmentRate: delivered / safe * 100,
      avgDeliveryDays: avgDeliveryDays,
      ordersGrowthPct: growth,
    );
  }

  // ══════════════════════════════════════════════════
  // COMPUTE PRODUCT METRICS
  // ══════════════════════════════════════════════════
  ProductMetrics _computeProductMetrics(
    List<Map<String, dynamic>> products,
  ) {
    final threshold = int.parse(
      dotenv.env['LOW_STOCK_THRESHOLD'] ?? '5',
    );

    int activeCount = 0;
    int outOfStock = 0;
    int lowStock = 0;
    double inventoryValue = 0;
    int totalSold = 0;
    int totalStock = 0;
    double ratingSum = 0;
    int ratedProducts = 0;
    int noSales = 0;

    for (final product in products) {
      final isActive = product['isActive'] as bool? ?? false;
      if (!isActive) continue;

      activeCount++;

      final price = (product['price'] as num?)?.toDouble() ?? 0;
      final stock = (product['totalStock'] as num?)?.toInt() ?? 0;
      final sold = (product['soldCount'] as num?)?.toInt() ?? 0;
      final rating = (product['avgRating'] as num?)?.toDouble() ?? 0;
      final reviewCount = (product['reviewCount'] as num?)?.toInt() ?? 0;

      // Inventory value = price × current stock
      inventoryValue += price * stock;
      totalSold += sold;
      totalStock += stock;

      if (stock == 0) {
        outOfStock++;
      } else if (stock <= threshold) {
        lowStock++;
      }

      if (reviewCount > 0) {
        ratingSum += rating;
        ratedProducts++;
      }

      if (sold == 0) noSales++;
    }

    // Sell-through = sold / (sold + stock) × 100
    final totalUnits = totalSold + totalStock;
    final sellThrough = totalUnits > 0 ? (totalSold / totalUnits * 100) : 0.0;

    final avgRating = ratedProducts > 0 ? ratingSum / ratedProducts : 0.0;

    return ProductMetrics(
      totalActiveProducts: activeCount,
      totalOutOfStock: outOfStock,
      totalLowStock: lowStock,
      inventoryValue: inventoryValue,
      sellThroughRate: sellThrough,
      totalUnitsSold: totalSold,
      avgProductRating: avgRating,
      productsWithNoSales: noSales,
    );
  }

  // ══════════════════════════════════════════════════
  // BUILD TIME SERIES (for line/bar charts)
  // Generates one point per day in the range
  // ══════════════════════════════════════════════════
  List<TimeSeriesPoint> _buildTimeSeries(
    List<Map<String, dynamic>> orders,
    DateRange range,
    String metric, // 'revenue' | 'count'
  ) {
    // Initialize all days in range with zero
    final days = <String, TimeSeriesPoint>{};
    final daysCount = range.daysCount.clamp(1, 365);

    for (int i = 0; i < daysCount; i++) {
      final date = range.start.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final label = _dayLabel(date, daysCount);
      days[key] = TimeSeriesPoint(
        date: date,
        value: 0,
        label: label,
        count: 0,
      );
    }

    // Aggregate delivered orders by day
    for (final order in orders) {
      if (order['status'] != OrderStatus.delivered) {
        continue;
      }
      final ts = (order['placedAt'] as Timestamp?)?.toDate();
      if (ts == null) continue;
      final key = DateFormat('yyyy-MM-dd').format(ts);
      final existing = days[key];
      if (existing == null) continue;

      final revenue = (order['total'] as num?)?.toDouble() ?? 0;

      days[key] = TimeSeriesPoint(
        date: existing.date,
        value: metric == 'revenue' ? existing.value + revenue : existing.value + 1,
        label: existing.label,
        count: existing.count + 1,
      );
    }

    return days.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  // Smart day label based on range size
  String _dayLabel(DateTime date, int totalDays) {
    if (totalDays <= 7) return DateFormat('EEE').format(date);
    if (totalDays <= 31) return DateFormat('dd').format(date);
    if (totalDays <= 90) return DateFormat('MMM dd').format(date);
    return DateFormat('MMM').format(date);
  }

  // ══════════════════════════════════════════════════
  // COMPUTE CATEGORY BREAKDOWN
  // ══════════════════════════════════════════════════
  Map<String, CategoryMetric> _computeCategoryBreakdown(
    List<Map<String, dynamic>> orders,
    List<Map<String, dynamic>> products,
  ) {
    // Build product → category lookup map
    final productCategoryMap = <String, String>{};
    final productCountByCategory = <String, int>{};
    for (final product in products) {
      final id = product['productId'] as String? ?? '';
      final cat = product['category'] as String? ?? 'Other';
      productCategoryMap[id] = cat;
      productCountByCategory[cat] = (productCountByCategory[cat] ?? 0) + 1;
    }

    // Aggregate revenue by category from order items
    final categoryRevenue = <String, double>{};
    final categoryUnitsSold = <String, int>{};

    for (final order in orders) {
      if (order['status'] != OrderStatus.delivered) {
        continue;
      }
      final items = order['items'] as List? ?? [];
      for (final item in items) {
        final map = item as Map<String, dynamic>;
        final productId = map['productId'] as String? ?? '';
        final category = productCategoryMap[productId] ?? 'Other';
        final lineTotal = (map['lineTotal'] as num?)?.toDouble() ?? 0;
        final qty = (map['quantity'] as num?)?.toInt() ?? 0;

        categoryRevenue[category] = (categoryRevenue[category] ?? 0) + lineTotal;
        categoryUnitsSold[category] = (categoryUnitsSold[category] ?? 0) + qty;
      }
    }

    // Compute revenue shares
    final totalRevenue = categoryRevenue.values.fold(0.0, (a, b) => a + b);

    return categoryRevenue.map((cat, rev) {
      final share = totalRevenue > 0 ? (rev / totalRevenue * 100) : 0.0;
      return MapEntry(
        cat,
        CategoryMetric(
          category: cat,
          revenue: rev,
          unitsSold: categoryUnitsSold[cat] ?? 0,
          productCount: productCountByCategory[cat] ?? 0,
          revenueShare: share,
          growthPct: 0, // computed if prev data available
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════
  // COMPUTE TOP PRODUCTS
  // ══════════════════════════════════════════════════
  List<TopProduct> _computeTopProducts(
    List<Map<String, dynamic>> orders,
    List<Map<String, dynamic>> products,
  ) {
    // Aggregate units + revenue per product from orders
    final productRevenue = <String, double>{};
    final productUnits = <String, int>{};

    for (final order in orders) {
      if (order['status'] != OrderStatus.delivered) {
        continue;
      }
      final items = order['items'] as List? ?? [];
      for (final item in items) {
        final map = item as Map<String, dynamic>;
        final pid = map['productId'] as String? ?? '';
        final lineTotal = (map['lineTotal'] as num?)?.toDouble() ?? 0;
        final qty = (map['quantity'] as num?)?.toInt() ?? 0;

        productRevenue[pid] = (productRevenue[pid] ?? 0) + lineTotal;
        productUnits[pid] = (productUnits[pid] ?? 0) + qty;
      }
    }

    // Build product lookup
    final productMap = <String, Map<String, dynamic>>{};
    for (final p in products) {
      final id = p['productId'] as String? ?? '';
      if (id.isNotEmpty) productMap[id] = p;
    }

    // Sort by units sold DESC
    final totalRevenue = productRevenue.values.fold(0.0, (a, b) => a + b);

    final sorted = productRevenue.entries.toList()
      ..sort((a, b) => (productUnits[b.key] ?? 0).compareTo(productUnits[a.key] ?? 0));

    return sorted.take(10).map((entry) {
      final p = productMap[entry.key];
      return TopProduct(
        productId: entry.key,
        productName: p?['name'] as String? ?? '',
        brand: p?['brand'] as String? ?? '',
        imageUrl: p?['thumbnailUrl'] as String? ?? '',
        category: p?['category'] as String? ?? '',
        unitsSold: productUnits[entry.key] ?? 0,
        revenue: entry.value,
        avgRating: (p?['avgRating'] as num?)?.toDouble() ?? 0,
        currentStock: (p?['totalStock'] as num?)?.toInt() ?? 0,
        revenueShare: totalRevenue > 0 ? (entry.value / totalRevenue * 100) : 0,
      );
    }).toList();
  }

  // ══════════════════════════════════════════════════
  // COMPUTE TOP CUSTOMERS (lifetime value)
  // ══════════════════════════════════════════════════
  Future<List<TopCustomer>> _computeTopCustomers() async {
    final snap = await _usersRef
        .where('role', isEqualTo: 'customer')
        .where('totalOrders', isGreaterThan: 0)
        .orderBy('totalOrders', descending: true)
        .orderBy('totalSpent', descending: true)
        .limit(10)
        .get();

    return snap.docs.map((doc) {
      final d = doc.data();
      return TopCustomer(
        userId: doc.id,
        displayName: d['displayName'] as String? ?? '',
        email: d['email'] as String? ?? '',
        photoUrl: d['photoUrl'] as String?,
        totalOrders: (d['totalOrders'] as num?)?.toInt() ?? 0,
        totalSpent: (d['totalSpent'] as num?)?.toDouble() ?? 0,
        eliteStatus: d['eliteStatus'] as String? ?? 'BRONZE',
        lastOrderDate: DateTime.now(), // simplified
      );
    }).toList();
  }

  // ── Customer stats fetch ───────────────────────────
  Future<_CustomerStatsRaw> _fetchCustomerStats(
    DateRange range,
  ) async {
    // New customers in period
    final newSnap = await _usersRef
        .where('role', isEqualTo: 'customer')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(range.end))
        .count()
        .get();

    // Total customers
    final totalSnap = await _usersRef.where('role', isEqualTo: 'customer').count().get();

    // Elite status counts
    final eliteSnap = await _usersRef.where('role', isEqualTo: 'customer').get();

    int bronze = 0, silver = 0, gold = 0, platinum = 0;
    double totalSpent = 0;
    int returningCount = 0;

    for (final doc in eliteSnap.docs) {
      final d = doc.data();
      final status = d['eliteStatus'] as String? ?? 'BRONZE';
      final orders = (d['totalOrders'] as num?)?.toInt() ?? 0;
      final spent = (d['totalSpent'] as num?)?.toDouble() ?? 0;
      totalSpent += spent;
      if (orders > 1) returningCount++;
      switch (status) {
        case 'BRONZE':
          bronze++;
          break;
        case 'SILVER':
          silver++;
          break;
        case 'GOLD':
          gold++;
          break;
        case 'PLATINUM':
          platinum++;
          break;
      }
    }

    return _CustomerStatsRaw(
      newCount: newSnap.count ?? 0,
      totalCount: totalSnap.count ?? 0,
      bronze: bronze,
      silver: silver,
      gold: gold,
      platinum: platinum,
      totalSpent: totalSpent,
      returningCount: returningCount,
    );
  }

  Future<_CustomerStatsRaw> _fetchPreviousCustomers(
    DateRange range,
  ) =>
      _fetchCustomerStats(range);

  CustomerMetrics _computeCustomerMetrics(
    _CustomerStatsRaw current,
    _CustomerStatsRaw previous,
    DateRange range,
  ) {
    final repeatRate = current.totalCount > 0 ? (current.returningCount / current.totalCount * 100) : 0.0;

    final avgLTV = current.totalCount > 0 ? current.totalSpent / current.totalCount : 0.0;

    final growth = previous.newCount > 0 ? ((current.newCount - previous.newCount) / previous.newCount * 100).round() : (current.newCount > 0 ? 100 : 0);

    return CustomerMetrics(
      totalCustomers: current.totalCount,
      newCustomers: current.newCount,
      returningCustomers: current.returningCount,
      repeatPurchaseRate: repeatRate,
      bronzeCount: current.bronze,
      silverCount: current.silver,
      goldCount: current.gold,
      platinumCount: current.platinum,
      avgLifetimeValue: avgLTV,
      customersGrowthPct: growth,
    );
  }
}

// Internal raw stats holder (not exposed to UI)
class _CustomerStatsRaw {
  final int newCount;
  final int totalCount;
  final int bronze, silver, gold, platinum;
  final double totalSpent;
  final int returningCount;

  const _CustomerStatsRaw({
    required this.newCount,
    required this.totalCount,
    required this.bronze,
    required this.silver,
    required this.gold,
    required this.platinum,
    required this.totalSpent,
    required this.returningCount,
  });
}

@riverpod
AnalyticsComputationService analyticsComputationService(
  AnalyticsComputationServiceRef ref,
) =>
    AnalyticsComputationService(ref.watch(firestoreProvider));
