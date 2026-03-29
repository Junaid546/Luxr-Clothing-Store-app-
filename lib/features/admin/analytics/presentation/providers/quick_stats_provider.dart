import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/providers/firebase_providers.dart';

part 'quick_stats_provider.g.dart';

@riverpod
Stream<Map<String, dynamic>> todayQuickStats(TodayQuickStatsRef ref) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final firestore = ref.watch(firestoreProvider);

  // Listen to orders placed today
  return firestore
      .collection(FirestoreConstants.orders)
      .where('placedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
      .snapshots()
      .map((snap) {
        double revenue = 0;
        var orderCount = 0;
        final customerIds = <String>{};

        for (final doc in snap.docs) {
          final data = doc.data();
          final status = data['status'] as String? ?? '';

          // Calculate revenue from delivered orders
          if (status == 'delivered') {
            revenue += (data['total'] as num?)?.toDouble() ?? 0.0;
          }

          // Total orders count (excluding cancelled if preferred, but usually count all pending/success)
          if (status != 'cancelled') {
            orderCount++;
          }

          final uid = data['userId'] as String? ?? '';
          if (uid.isNotEmpty) {
            customerIds.add(uid);
          }
        }

        final todayStr = DateFormat('yyyy-MM-dd').format(now);
        return {
          'revenue': revenue,
          'orderCount': orderCount,
          'newCustomers': customerIds.length, // approximation for real-time
          'avgOrderValue': orderCount > 0 ? revenue / orderCount : 0.0,
          'date': todayStr,
          'isRealtime': true,
        };
      });
}
