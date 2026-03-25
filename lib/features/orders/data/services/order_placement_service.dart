import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';
import 'package:style_cart/core/errors/exceptions.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/providers/firebase_providers.dart';
import 'package:style_cart/core/providers/repository_providers.dart' hide firestoreProvider;
import 'package:style_cart/features/auth/domain/entities/user_entity.dart';
import 'package:style_cart/features/cart/domain/entities/cart_entity.dart';
import 'package:style_cart/features/orders/data/models/order_model.dart';
import 'package:style_cart/features/cart/domain/repositories/cart_repository.dart';

part 'order_placement_service.g.dart';

class OrderPlacementService {
  final FirebaseFirestore _firestore;
  final CartRepository _cartRepo;

  const OrderPlacementService({
    required FirebaseFirestore firestore,
    required CartRepository cartRepo,
  })  : _firestore = firestore,
        _cartRepo = cartRepo;

  // ══════════════════════════════════════════════════
  // PLACE ORDER — Single atomic operation
  // ══════════════════════════════════════════════════
  Future<Either<Failure, String>> placeOrder({
    required CartValidationResult validatedCart,
    required UserEntity user,
    required ShippingAddressModel shippingAddress,
    required String shippingMethod,
    required String paymentMethod,
    required double discountAmount,
  }) async {
    try {
      // 1. Generate order ID before transaction
      final orderId = _generateOrderId();

      // 2. Compute order totals from VALIDATED items
      final items = validatedCart.validatedItems;
      final subtotal = items.fold(
        0.0,
        (sum, item) => sum + (item.finalPrice * item.quantity),
      );
      final shippingCost = shippingMethod == ShippingMethod.express
          ? double.parse(
              dotenv.env['EXPRESS_SHIPPING_COST'] ?? '25',
            )
          : 0.0;
      final total = subtotal + shippingCost - discountAmount;

      // 3. Build order items (snapshot prices)
      final orderItems = items
          .map(
            (item) => OrderItemModel(
              productId: item.productId,
              productName: item.productName,
              brand: item.brand,
              imageUrl: item.imageUrl,
              size: item.size,
              color: item.color,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              discountPct: item.discountPct,
              finalPrice: item.finalPrice,
              lineTotal: item.finalPrice * item.quantity,
            ),
          )
          .toList();

      // 4. Compute estimated delivery
      final estimatedDelivery = EstimatedDeliveryModel.forMethod(shippingMethod);

      // ── BEGIN TRANSACTION ────────────────────────
      await _firestore.runTransaction((txn) async {
        final productsRef = _firestore.collection(FirestoreConstants.products);
        final usersRef = _firestore.collection(FirestoreConstants.users);
        final ordersRef = _firestore.collection(FirestoreConstants.orders);

        // ── PHASE 1: READ ALL PRODUCTS ─────────────
        final productDocRefs = items.map((i) => productsRef.doc(i.productId)).toList();

        final productSnaps = await Future.wait(
          productDocRefs.map((ref) => txn.get(ref)),
        );

        // ── PHASE 2: READ USER ─────────────────────
        final userRef = usersRef.doc(user.uid);
        final userSnap = await txn.get(userRef);

        // ── PHASE 3: VALIDATE ALL STOCK ───────────
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          final snap = productSnaps[i];

          if (!snap.exists) {
            throw NotFoundException(
              '${item.productName} is no longer available',
            );
          }

          final data = snap.data()!;

          if (data['isActive'] == false) {
            throw ValidationException(
              '${item.productName} has been discontinued',
            );
          }

          final inv = Map<String, dynamic>.from(
            data['inventory'] as Map? ?? {},
          );
          final available = (inv[item.size] as num?)?.toInt() ?? 0;

          if (available < item.quantity) {
            throw StockException(
              available == 0
                  ? '${item.productName} (Size ${item.size}) just sold out'
                  : '${item.productName} (Size ${item.size}): only $available left',
            );
          }
        }

        // ── PHASE 4: WRITE STOCK DEDUCTIONS ───────
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          final data = productSnaps[i].data()!;
          final inv = Map<String, dynamic>.from(
            data['inventory'] as Map? ?? {},
          );

          final currentQty = (inv[item.size] as num?)?.toInt() ?? 0;
          final currentTotal = (data['totalStock'] as num?)?.toInt() ?? 0;
          final currentSold = (data['soldCount'] as num?)?.toInt() ?? 0;

          txn.update(productDocRefs[i], {
            'inventory.${item.size}': currentQty - item.quantity,
            'totalStock': currentTotal - item.quantity,
            'soldCount': currentSold + item.quantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        // ── PHASE 5: CREATE ORDER DOCUMENT ────────
        final orderRef = ordersRef.doc(orderId);
        txn.set(orderRef, {
          'orderId': orderId,
          'userId': user.uid,
          'userEmail': user.email,
          'userName': user.displayName,
          'items': orderItems.map((i) => i.toMap()).toList(),
          'subtotal': subtotal,
          'shippingCost': shippingCost,
          'discountAmount': discountAmount,
          'taxAmount': 0.0,
          'total': total,
          'shippingMethod': shippingMethod,
          'shippingAddress': shippingAddress.toMap(),
          'estimatedDelivery': estimatedDelivery.toMap(),
          'paymentMethod': paymentMethod,
          'paymentStatus': paymentMethod == PaymentMethod.online ? PaymentStatus.paid : PaymentStatus.pending,
          'transactionId': null,
          'status': OrderStatus.pending,
          'statusHistory': [
            {
              'status': OrderStatus.pending,
              'timestamp': FieldValue.serverTimestamp(),
              'note': 'Order placed successfully',
              'updatedBy': 'system',
            },
          ],
          'courier': null,
          'placedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'deliveredAt': null,
        });

        // ── PHASE 6: UPDATE USER STATS ─────────────
        final userData = userSnap.data() ?? {};
        final currentOrders = (userData['totalOrders'] as num?)?.toInt() ?? 0;
        final currentSpent = (userData['totalSpent'] as num?)?.toDouble() ?? 0.0;
        
        final newOrderCount = currentOrders + 1;
        final newTotalSpent = currentSpent + total;
        final newEliteStatus = newOrderCount.eliteStatus;

        txn.update(userRef, {
          'totalOrders': newOrderCount,
          'totalSpent': newTotalSpent,
          'eliteStatus': newEliteStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      // ── END TRANSACTION ──────────────────────────

      // 6. Clear cart AFTER transaction succeeds
      unawaited(_cartRepo.clearCart(user.uid));

      return Right(orderId);
    } on StockException catch (e) {
      return Left(StockFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Order placement failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── Order ID generation ────────────────────────────
  String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7); // last 6 digits
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'SC-$timestamp-$random'.toUpperCase();
  }
}

@riverpod
OrderPlacementService orderPlacementService(OrderPlacementServiceRef ref) => OrderPlacementService(
      firestore: ref.watch(firestoreProvider),
      cartRepo: ref.watch(cartRepositoryProvider),
    );
