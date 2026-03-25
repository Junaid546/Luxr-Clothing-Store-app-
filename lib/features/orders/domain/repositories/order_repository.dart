import 'package:dartz/dartz.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';

abstract interface class OrderRepository {

  // ── Customer operations ───────────────────────────

  // Real-time stream of single order (for tracking)
  Stream<Either<Failure, OrderEntity>> watchOrder(
    String orderId,
  );

  // Real-time stream of user's orders
  Stream<Either<Failure, List<OrderEntity>>> watchUserOrders(
    String userId,
  );

  // One-time fetch
  Future<Either<Failure, OrderEntity>> getOrderById(
    String orderId,
  );

  // Paginated user orders
  Future<Either<Failure, List<OrderEntity>>> getUserOrders({
    required String userId,
    String? statusFilter,
    int limit = 10,
    Object? lastDocument,
  });

  // Cancel order (only pending/confirmed)
  Future<Either<Failure, void>> cancelOrder({
    required String orderId,
    required String userId,
    required List<OrderItemEntity> items,
    String? reason,
  });

  // Request return (only delivered within 7 days)
  Future<Either<Failure, void>> requestReturn({
    required String orderId,
    required String userId,
    required String reason,
  });

  // ── Admin operations ──────────────────────────────

  // All orders (paginated + filtered)
  Future<Either<Failure, List<OrderEntity>>> getAllOrders({
    String? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    Object? lastDocument,
  });

  // Real-time stream of all orders (admin dashboard)
  Stream<Either<Failure, List<OrderEntity>>> watchAllOrders({
    String? statusFilter,
    int limit = 20,
  });

  // Update order status (admin)
  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String newStatus,
    required String updatedBy,
    String? note,
    CourierEntity? courier,
  });

  // Confirm return + release stock (admin)
  Future<Either<Failure, void>> confirmReturn({
    required String orderId,
    required List<OrderItemEntity> items,
    required String adminId,
  });

  // Search orders by ID or user email (admin)
  Future<Either<Failure, List<OrderEntity>>> searchOrders(
    String query,
  );
}
