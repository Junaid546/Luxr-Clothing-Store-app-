import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stylecart/core/constants/firestore_constants.dart';
import 'package:stylecart/core/providers/firebase_providers.dart';
import 'package:stylecart/features/admin/analytics/data/services/analytics_computation_service.dart';
import 'package:stylecart/features/admin/analytics/domain/models/analytics_models.dart';

part 'analytics_cache_service.g.dart';

// ══════════════════════════════════════════════════════
// ANALYTICS CACHE SERVICE
// Pre-aggregates daily stats into /analytics/{YYYY-MM-DD}
// Uses SetOptions(merge: true) for idempotency — safe to
// call multiple times per day without overwriting.
// ══════════════════════════════════════════════════════

class AnalyticsCacheService {
  final FirebaseFirestore _firestore;
  final AnalyticsComputationService _computeService;

  const AnalyticsCacheService(
    this._firestore,
    this._computeService,
  );

  // ── Write daily snapshot ──────────────────────────
  // Computes metrics for the given date and persists them
  // to /analytics/{YYYY-MM-DD} using merge (idempotent).
  Future<void> writeDailySnapshot(DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    final report = await _computeService.generateReport(
      'custom',
      customRange: DateRange(start: dayStart, end: dayEnd),
    );

    final dateKey = DateFormat('yyyy-MM-dd').format(date);

    await _firestore.collection(FirestoreConstants.analytics).doc(dateKey).set(
      {
        'date': dateKey,
        'revenue': report.revenue.totalRevenue,
        'orderCount': report.orders.totalOrders,
        'newCustomers': report.customers.newCustomers,
        'cancelledOrders': report.orders.cancelledOrders,
        'avgOrderValue': report.revenue.avgOrderValue,
        'topProducts': report.topProducts
            .take(5)
            .map((p) => {
                  'productId': p.productId,
                  'name': p.productName,
                  'unitsSold': p.unitsSold,
                  'revenue': p.revenue,
                })
            .toList(),
        'revenueByCategory': report.categoryBreakdown.map(
          (k, v) => MapEntry(k, v.revenue),
        ),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true), // idempotent — safe to re-run
    );

    debugPrint('[AnalyticsCache] Snapshot written for $dateKey');
  }

  // ── Read cached snapshots for a date range ────────
  // Returns raw Firestore data maps sorted by date ASC.
  Future<List<Map<String, dynamic>>> readCachedRange(
    DateRange range,
  ) async {
    final startKey = DateFormat('yyyy-MM-dd').format(range.start);
    final endKey = DateFormat('yyyy-MM-dd').format(range.end);

    final snap = await _firestore
        .collection(FirestoreConstants.analytics)
        .where('date', isGreaterThanOrEqualTo: startKey)
        .where('date', isLessThanOrEqualTo: endKey)
        .orderBy('date', descending: false)
        .get();

    return snap.docs.map((d) => d.data()).toList();
  }
}

@riverpod
AnalyticsCacheService analyticsCacheService(
  AnalyticsCacheServiceRef ref,
) =>
    AnalyticsCacheService(
      ref.watch(firestoreProvider),
      ref.watch(analyticsComputationServiceProvider),
    );
