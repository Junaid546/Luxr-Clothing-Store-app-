import 'package:dartz/dartz.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/features/admin/dashboard/domain/models/dashboard_stats_model.dart';
import 'package:stylecart/features/products/domain/entities/product_entity.dart';

abstract interface class DashboardRepository {
  Future<Either<Failure, DashboardStats>> getStats({
    required DateTime periodStart,
    required DateTime periodEnd,
  });

  Future<Either<Failure, WeeklyRevenueData>> getWeeklyRevenue();

  Future<Either<Failure, List<ProductEntity>>> getTopSellingProducts({
    int limit = 5,
  });

  Stream<Either<Failure, List<ActivityItem>>> watchRecentActivity({
    int limit = 10,
  });

  Future<Either<Failure, int>> getLowStockCount();
}
