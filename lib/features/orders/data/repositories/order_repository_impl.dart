import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';
import 'package:style_cart/core/data/firestore_base_repository.dart';
import 'package:style_cart/core/errors/exceptions.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/orders/data/models/order_model.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';
import 'package:style_cart/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl
    extends FirestoreBaseRepository
    implements OrderRepository {

  OrderRepositoryImpl(super.firestore);

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      firestore.collection(FirestoreConstants.orders);

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      firestore.collection(FirestoreConstants.products);

  // ══════════════════════════════════════════════════
  // WATCH SINGLE ORDER — Real-time tracking stream
  // ══════════════════════════════════════════════════
  @override
  Stream<Either<Failure, OrderEntity>> watchOrder(
    String orderId,
  ) {
    return safeFirestoreStream(() =>
      _ordersRef.doc(orderId)
          .snapshots()
          .where((doc) => doc.exists)
          .map(OrderModel.fromFirestore),
    );
  }

  // ══════════════════════════════════════════════════
  // WATCH USER ORDERS — Real-time customer orders
  // ══════════════════════════════════════════════════
  @override
  Stream<Either<Failure, List<OrderEntity>>> watchUserOrders(
    String userId,
  ) {
    return safeFirestoreStream(() =>
      _ordersRef
          .where('userId', isEqualTo: userId)
          .orderBy('placedAt', descending: true)
          .limit(20)
          .snapshots()
          .map((snap) => snap.docs
              .map(OrderModel.fromFirestore)
              .toList()),
    );
  }

  // ══════════════════════════════════════════════════
  // GET ORDER BY ID
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, OrderEntity>> getOrderById(
    String orderId,
  ) {
    return safeFirestoreCall(() async {
      final doc = await _ordersRef.doc(orderId).get();
      if (!doc.exists) {
        throw const NotFoundException('Order not found');
      }
      return OrderModel.fromFirestore(doc);
    });
  }

  // ══════════════════════════════════════════════════
  // GET USER ORDERS — Paginated
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, List<OrderEntity>>> getUserOrders({
    required String userId,
    String? statusFilter,
    int limit = 10,
    Object? lastDocument,
  }) {
    return safeFirestoreCall(() async {
      Query<Map<String, dynamic>> query = _ordersRef
          .where('userId', isEqualTo: userId)
          .orderBy('placedAt', descending: true);

      if (statusFilter != null && statusFilter != 'all') {
        query = query.where(
          'status', isEqualTo: statusFilter,
        );
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(
          lastDocument as DocumentSnapshot,
        );
      }

      final snap = await query.limit(limit).get();
      return snap.docs
          .map(OrderModel.fromFirestore)
          .toList();
    });
  }

  // ══════════════════════════════════════════════════
  // CANCEL ORDER — Releases stock atomically
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> cancelOrder({
    required String orderId,
    required String userId,
    required List<OrderItemEntity> items,
    String? reason,
  }) {
    return safeFirestoreCall(() async {

      await firestore.runTransaction((txn) async {

        // READ order first to verify it can be cancelled
        final orderRef = _ordersRef.doc(orderId);
        final orderSnap = await txn.get(orderRef);

        if (!orderSnap.exists) {
          throw const NotFoundException('Order not found');
        }

        final orderData = orderSnap.data()!;
        final currentStatus =
            orderData['status'] as String? ?? '';

        // Security: verify this order belongs to user
        if (orderData['userId'] != userId) {
          throw const PermissionException(
            'You cannot cancel this order',
          );
        }

        // Verify cancellable status
        if (![
          OrderStatus.pending,
          OrderStatus.confirmed,
        ].contains(currentStatus)) {
          throw ValidationException(
            'Order cannot be cancelled in '
            '$currentStatus status',
          );
        }

        // READ all products for stock release
        final productRefs = items
            .map((i) => _productsRef.doc(i.productId))
            .toList();
        
        // We can't use await Future.wait inside txn for multiple distinct docs if we need to guarantee consistency properly in some Firestore versions,
        // but here it's fine as we are just reading them.
        final productSnaps = <DocumentSnapshot<Map<String, dynamic>>>[];
        for (final ref in productRefs) {
          productSnaps.add(await txn.get(ref));
        }

        // WRITE: Update order status
        txn.update(orderRef, {
          'status':    OrderStatus.cancelled,
          'updatedAt': FieldValue.serverTimestamp(),
          'statusHistory': FieldValue.arrayUnion([{
            'status':    OrderStatus.cancelled,
            'timestamp': Timestamp.now(),
            'note':      reason ?? 'Cancelled by customer',
            'updatedBy': userId,
          }]),
        });

        // WRITE: Release stock for all items
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          final snap = productSnaps[i];

          if (!snap.exists) continue; // product deleted — skip

          final data = snap.data()!;
          final inv = Map<String, dynamic>.from(
            data['inventory'] as Map? ?? {},
          );
          final currentQty =
              (inv[item.size] as num?)?.toInt() ?? 0;
          final currentTotal =
              (data['totalStock'] as num?)?.toInt() ?? 0;
          final currentSold =
              (data['soldCount'] as num?)?.toInt() ?? 0;

          txn.update(productRefs[i], {
            'inventory.${item.size}':
                currentQty + item.quantity,
            'totalStock':
                currentTotal + item.quantity,
            'soldCount': (currentSold - item.quantity)
                .clamp(0, double.maxFinite.toInt()),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    });
  }

  // ══════════════════════════════════════════════════
  // REQUEST RETURN — Customer initiates return
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> requestReturn({
    required String orderId,
    required String userId,
    required String reason,
  }) {
    return safeFirestoreCall(() async {
      final orderDoc = await _ordersRef.doc(orderId).get();

      if (!orderDoc.exists) {
        throw const NotFoundException('Order not found');
      }

      final data = orderDoc.data()!;

      // Security check
      if (data['userId'] != userId) {
        throw const PermissionException(
          'You cannot request return for this order',
        );
      }

      // Status check
      if (data['status'] != OrderStatus.delivered) {
        throw const ValidationException(
          'Only delivered orders can be returned',
        );
      }

      // 7-day return window check
      final deliveredAt =
          (data['deliveredAt'] as Timestamp?)?.toDate();
      if (deliveredAt != null) {
        final daysSinceDelivery =
            DateTime.now().difference(deliveredAt).inDays;
        if (daysSinceDelivery > 7) {
          throw const ValidationException(
            'Return window has expired (7 days from delivery)',
          );
        }
      }

      await _ordersRef.doc(orderId).update({
        'status':    OrderStatus.returnRequested,
        'updatedAt': FieldValue.serverTimestamp(),
        'statusHistory': FieldValue.arrayUnion([{
          'status':    OrderStatus.returnRequested,
          'timestamp': Timestamp.now(),
          'note':      reason,
          'updatedBy': userId,
        }]),
      });
    });
  }

  // ══════════════════════════════════════════════════
  // GET ALL ORDERS — Admin paginated + filtered
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, List<OrderEntity>>> getAllOrders({
    String? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    Object? lastDocument,
  }) {
    return safeFirestoreCall(() async {
      Query<Map<String, dynamic>> query = _ordersRef
          .orderBy('placedAt', descending: true);

      if (statusFilter != null && statusFilter != 'all') {
        query = _ordersRef
            .where('status', isEqualTo: statusFilter)
            .orderBy('placedAt', descending: true);
      }

      if (fromDate != null) {
        query = query.where(
          'placedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
        );
      }

      if (toDate != null) {
        query = query.where(
          'placedAt',
          isLessThanOrEqualTo: Timestamp.fromDate(toDate),
        );
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(
          lastDocument as DocumentSnapshot,
        );
      }

      final snap = await query.limit(limit).get();
      return snap.docs
          .map(OrderModel.fromFirestore)
          .toList();
    });
  }

  // ══════════════════════════════════════════════════
  // WATCH ALL ORDERS — Admin real-time dashboard
  // ══════════════════════════════════════════════════
  @override
  Stream<Either<Failure, List<OrderEntity>>> watchAllOrders({
    String? statusFilter,
    int limit = 20,
  }) {
    Query<Map<String, dynamic>> query;

    if (statusFilter != null && statusFilter != 'all') {
      query = _ordersRef
          .where('status', isEqualTo: statusFilter)
          .orderBy('placedAt', descending: true)
          .limit(limit);
    } else {
      query = _ordersRef
          .orderBy('placedAt', descending: true)
          .limit(limit);
    }

    return safeFirestoreStream(() =>
      query.snapshots().map((snap) =>
          snap.docs.map(OrderModel.fromFirestore).toList()),
    );
  }

  // ══════════════════════════════════════════════════
  // UPDATE ORDER STATUS — Admin action
  // Appends to statusHistory (never overwrites)
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String newStatus,
    required String updatedBy,
    String? note,
    CourierEntity? courier,
  }) {
    return safeFirestoreCall(() async {
      final updateData = <String, dynamic>{
        'status':    newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'statusHistory': FieldValue.arrayUnion([{
          'status':    newStatus,
          'timestamp': Timestamp.now(),
          'note':      note ?? _defaultNote(newStatus),
          'updatedBy': updatedBy,
        }]),
      };

      // Add courier info when shipped
      if (newStatus == OrderStatus.shipped &&
          courier != null) {
        updateData['courier'] = {
          'name':          courier.name,
          'trackingNumber':courier.trackingNumber,
          'estimatedTime': courier.estimatedTime,
        };
      }

      // Set deliveredAt timestamp
      if (newStatus == OrderStatus.delivered) {
        updateData['deliveredAt'] =
            FieldValue.serverTimestamp();
        updateData['paymentStatus'] = 'paid';
      }

      await _ordersRef.doc(orderId).update(updateData);
    });
  }

  // ══════════════════════════════════════════════════
  // CONFIRM RETURN — Admin confirms + releases stock
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> confirmReturn({
    required String orderId,
    required List<OrderItemEntity> items,
    required String adminId,
  }) {
    return safeFirestoreCall(() async {
      await firestore.runTransaction((txn) async {

        final orderRef = _ordersRef.doc(orderId);
        final orderSnap = await txn.get(orderRef);

        if (!orderSnap.exists) {
          throw const NotFoundException('Order not found');
        }

        final data = orderSnap.data()!;
        if (data['status'] != OrderStatus.returnRequested) {
          throw const ValidationException(
            'Order is not in return_requested status',
          );
        }

        // READ products for stock release
        final productRefs = items
            .map((i) => _productsRef.doc(i.productId))
            .toList();
        
        final productSnaps = <DocumentSnapshot<Map<String, dynamic>>>[];
        for (final ref in productRefs) {
          productSnaps.add(await txn.get(ref));
        }

        // UPDATE order status
        txn.update(orderRef, {
          'status':       OrderStatus.returned,
          'paymentStatus': 'refunded',
          'updatedAt':    FieldValue.serverTimestamp(),
          'statusHistory': FieldValue.arrayUnion([{
            'status':    OrderStatus.returned,
            'timestamp': Timestamp.now(),
            'note':      'Return confirmed by admin',
            'updatedBy': adminId,
          }]),
        });

        // RELEASE stock
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          final snap = productSnaps[i];
          if (!snap.exists) continue;

          final d = snap.data()!;
          final inv = Map<String, dynamic>.from(
            d['inventory'] as Map? ?? {},
          );
          final currentQty =
              (inv[item.size] as num?)?.toInt() ?? 0;
          final currentTotal =
              (d['totalStock'] as num?)?.toInt() ?? 0;
          final currentSold =
              (d['soldCount'] as num?)?.toInt() ?? 0;

          txn.update(productRefs[i], {
            'inventory.${item.size}':
                currentQty + item.quantity,
            'totalStock':
                currentTotal + item.quantity,
            'soldCount': (currentSold - item.quantity)
                .clamp(0, double.maxFinite.toInt()),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    });
  }

  // ══════════════════════════════════════════════════
  // SEARCH ORDERS — Admin search by ID or email
  // ══════════════════════════════════════════════════
  @override
  Future<Either<Failure, List<OrderEntity>>> searchOrders(
    String query,
  ) {
    return safeFirestoreCall(() async {
      if (query.trim().isEmpty) return [];

      final results = <OrderEntity>[];

      // Search by exact order ID
      if (query.toUpperCase().startsWith('SC-')) {
        final doc = await _ordersRef
            .doc(query.toUpperCase())
            .get();
        if (doc.exists) {
          results.add(OrderModel.fromFirestore(doc));
        }
        return results;
      }

      // Search by user email (exact match)
      final emailSnap = await _ordersRef
          .where('userEmail', isEqualTo: query.toLowerCase())
          .orderBy('placedAt', descending: true)
          .limit(20)
          .get();

      results.addAll(
        emailSnap.docs.map(OrderModel.fromFirestore),
      );

      return results;
    });
  }

  // ── Default status notes ───────────────────────────
  String _defaultNote(String status) => switch (status) {
    OrderStatus.confirmed      => 'Order confirmed',
    OrderStatus.processing     => 'Being prepared',
    OrderStatus.packed         => 'Packed and ready',
    OrderStatus.shipped        => 'Shipped to courier',
    OrderStatus.outForDelivery => 'Out for delivery',
    OrderStatus.delivered      => 'Delivered successfully',
    OrderStatus.cancelled      => 'Order cancelled',
    OrderStatus.returned       => 'Return processed',
    _                          => 'Status updated',
  };
}
