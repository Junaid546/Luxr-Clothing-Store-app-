import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';
import 'package:style_cart/core/data/firestore_base_repository.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/providers/firebase_providers.dart';
import 'package:style_cart/features/admin/dashboard/data/repositories/dashboard_repository.dart';
import 'package:style_cart/features/admin/dashboard/domain/models/dashboard_stats_model.dart';
import 'package:style_cart/features/products/data/models/product_model.dart';
import 'package:style_cart/features/products/domain/entities/product_entity.dart';

part 'dashboard_repository_impl.g.dart';

class DashboardRepositoryImpl extends FirestoreBaseRepository
    implements DashboardRepository {
  DashboardRepositoryImpl(super.firestore);

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      firestore.collection(FirestoreConstants.orders);

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      firestore.collection(FirestoreConstants.users);

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      firestore.collection(FirestoreConstants.products);

  @override
  Future<Either<Failure, DashboardStats>> getStats({
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    return safeFirestoreCall(() async {
      try {
        final periodDuration = periodEnd.difference(periodStart);
        final prevStart = periodStart.subtract(periodDuration);
        final prevEnd = periodStart;

        // 1. Current period revenue
        final currentOrdersSnap = await _ordersRef
            .where('status', isEqualTo: OrderStatus.delivered)
            .where('placedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(periodStart))
            .where('placedAt', isLessThanOrEqualTo: Timestamp.fromDate(periodEnd))
            .get();

        double currentRevenue = 0;
        for (final doc in currentOrdersSnap.docs) {
          currentRevenue += (doc.data()['total'] as num?)?.toDouble() ?? 0.0;
        }
        final currentOrderCount = currentOrdersSnap.docs.length;

        // 2. Previous period revenue for % change
        final prevOrdersSnap = await _ordersRef
            .where('status', isEqualTo: OrderStatus.delivered)
            .where('placedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(prevStart))
            .where('placedAt', isLessThanOrEqualTo: Timestamp.fromDate(prevEnd))
            .get();

        double prevRevenue = 0;
        for (final doc in prevOrdersSnap.docs) {
          prevRevenue += (doc.data()['total'] as num?)?.toDouble() ?? 0.0;
        }
        final prevOrderCount = prevOrdersSnap.docs.length;

        // 3. New clients
        final newClientsSnap = await _usersRef
            .where('role', isEqualTo: 'customer')
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(periodStart))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(periodEnd))
            .count()
            .get();

        final newClients = newClientsSnap.count ?? 0;

        final prevClientsSnap = await _usersRef
            .where('role', isEqualTo: 'customer')
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(prevStart))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(prevEnd))
            .count()
            .get();

        final prevClients = prevClientsSnap.count ?? 0;

        // 4. All-time stats
        final allTimeRevenueSnap = await _ordersRef
            .where('status', isEqualTo: OrderStatus.delivered)
            .get();
        
        double allTimeRevenue = 0;
        for (final doc in allTimeRevenueSnap.docs) {
          allTimeRevenue += (doc.data()['total'] as num?)?.toDouble() ?? 0.0;
        }

        final allOrdersCount = await _ordersRef.count().get();
        final allClientsCount = await _usersRef.where('role', isEqualTo: 'customer').count().get();

        double pctChange(double current, double prev) {
          if (prev == 0) return current > 0 ? 100.0 : 0.0;
          return ((current - prev) / prev) * 100;
        }

        return DashboardStats(
          totalRevenue: allTimeRevenue,
          totalOrders: allOrdersCount.count ?? 0,
          newClients: newClients,
          totalClients: allClientsCount.count ?? 0,
          conversionRate: currentOrderCount > 0
              ? (currentOrderCount / (newClients > 0 ? newClients : 1) * 100).clamp(0.0, 100.0)
              : 0.0,
          revenueChange: pctChange(currentRevenue, prevRevenue),
          ordersChange: pctChange(currentOrderCount.toDouble(), prevOrderCount.toDouble()),
          clientsChange: pctChange(newClients.toDouble(), prevClients.toDouble()),
          conversionChange: 0,
        );
      } catch (e) {
        if (kDebugMode && e is FirebaseException && e.code == 'permission-denied') {
          debugPrint('[DashboardRepository] Permission denied in getStats. Returning empty stats.');
          return DashboardStats.empty;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, WeeklyRevenueData>> getWeeklyRevenue() {
    return safeFirestoreCall(() async {
      try {
        final now = DateTime.now();
        final weekStart = DateTime(now.year, now.month, now.day - 6);

        final snap = await _ordersRef
            .where('placedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
            .where('status', isEqualTo: OrderStatus.delivered)
            .orderBy('placedAt', descending: false)
            .get();

        final dailyMap = <String, DailyRevenue>{};
        for (var i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final key = DateFormat('yyyy-MM-dd').format(date);
          dailyMap[key] = DailyRevenue(date: date, revenue: 0, orderCount: 0);
        }

        for (final doc in snap.docs) {
          final data = doc.data();
          final timestamp = (data['placedAt'] as Timestamp?)?.toDate();
          if (timestamp == null) continue;

          final key = DateFormat('yyyy-MM-dd').format(timestamp);
          if (dailyMap.containsKey(key)) {
            final existing = dailyMap[key]!;
            final revenue = (data['total'] as num?)?.toDouble() ?? 0.0;
            dailyMap[key] = DailyRevenue(
              date: existing.date,
              revenue: existing.revenue + revenue,
              orderCount: existing.orderCount + 1,
            );
          }
        }

        return WeeklyRevenueData(days: dailyMap.values.toList());
      } catch (e) {
        if (kDebugMode && e is FirebaseException && e.code == 'permission-denied') {
          debugPrint('[DashboardRepository] Permission denied in getWeeklyRevenue. Returning empty data.');
          return const WeeklyRevenueData(days: []);
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getTopSellingProducts({int limit = 5}) {
    return safeFirestoreCall(() async {
      final snap = await _productsRef
          .where('isActive', isEqualTo: true)
          .orderBy('soldCount', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((doc) => ProductModel.fromFirestore(doc).toEntity()).toList();
    });
  }

  @override
  Stream<Either<Failure, List<ActivityItem>>> watchRecentActivity({int limit = 10}) {
    return safeFirestoreStream(() => _ordersRef
        .orderBy('placedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              return ActivityItem(
                type: 'order',
                title: 'New order #${doc.id}',
                subtitle: data['userName'] as String? ?? 'Unknown Customer',
                amount: (data['total'] as num?)?.toDouble(),
                timestamp: (data['placedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                orderId: doc.id,
                userId: data['userId'] as String?,
              );
            }).toList()));
  }

  @override
  Future<Either<Failure, int>> getLowStockCount() {
    return safeFirestoreCall(() async {
      try {
        final threshold = int.tryParse(dotenv.env['LOW_STOCK_THRESHOLD'] ?? '5') ?? 5;
        final snap = await _productsRef
            .where('isActive', isEqualTo: true)
            .where('totalStock', isLessThanOrEqualTo: threshold)
            .count()
            .get();
        return snap.count ?? 0;
      } catch (e) {
        if (kDebugMode && e is FirebaseException && e.code == 'permission-denied') {
          debugPrint('[DashboardRepository] Permission denied in getLowStockCount. Returning 0.');
          return 0;
        }
        rethrow;
      }
    });
  }
}

@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) =>
    DashboardRepositoryImpl(ref.watch(firestoreProvider));
