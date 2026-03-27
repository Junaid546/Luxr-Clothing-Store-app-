import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/providers/firebase_providers.dart';
import 'package:style_cart/features/admin/analytics/data/services/analytics_computation_service.dart';

part 'quick_stats_provider.g.dart';

// ══════════════════════════════════════════════════════
// TODAY QUICK STATS PROVIDER
// Lightweight stats for the Admin Dashboard.
// Strategy: reads /analytics/{today} cache first;
// falls back to live AnalyticsComputationService if
// no snapshot is found for today.
// ══════════════════════════════════════════════════════

@riverpod
Future<Map<String, dynamic>> todayQuickStats(
  TodayQuickStatsRef ref,
) async {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final firestore = ref.watch(firestoreProvider);

  // 1. Try Firestore cache first
  try {
    final cached = await firestore
        .collection(FirestoreConstants.analytics)
        .doc(today)
        .get();

    if (cached.exists && cached.data() != null) {
      return cached.data()!;
    }
  } catch (_) {
    // Cache miss or Firestore error — fall through to live
  }

  // 2. Fall back to live computation
  final report = await ref
      .read(analyticsComputationServiceProvider)
      .generateReport('today');

  return {
    'revenue': report.revenue.totalRevenue,
    'orderCount': report.orders.totalOrders,
    'newCustomers': report.customers.newCustomers,
    'avgOrderValue': report.revenue.avgOrderValue,
    'date': today,
  };
}
