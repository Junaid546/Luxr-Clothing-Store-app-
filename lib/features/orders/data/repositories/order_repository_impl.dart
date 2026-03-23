// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/data/firestore_base_repository.dart';
import 'package:style_cart/core/errors/exceptions.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/cart/data/models/cart_item_model.dart';
import 'package:style_cart/features/orders/data/models/order_model.dart';
import 'package:style_cart/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl extends FirestoreBaseRepository implements OrderRepository {
  OrderRepositoryImpl(super.firestore);

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      firestore.collection(FirestoreConstants.orders);

  @override
  Future<Either<Failure, void>> placeOrder({
    required String userId,
    required OrderModel order,
    required List<CartItemModel> cartItems,
  }) {
    return safeFirestoreCall(() async {
      await firestore.runTransaction((transaction) async {
        final productRefs = cartItems
            .map((item) => firestore.collection(FirestoreConstants.products).doc(item.productId))
            .toList();
            
        final snapshots = await Future.wait(
          productRefs.map((ref) => transaction.get(ref)),
        );
        
        final updatedItems = <OrderItemModel>[];
        var newSubtotal = 0.0;
        
        // VALIDATE all products and re-calculate prices
        for (var i = 0; i < cartItems.length; i++) {
          final cartItem = cartItems[i];
          final productSnap = snapshots[i];
          
          if (!productSnap.exists) {
            throw NotFoundException('Product ${cartItem.productName} not found');
          }
          
          final data = productSnap.data()!;
          if (data['isActive'] != true) {
            throw StockException('Product ${cartItem.productName} is no longer available');
          }
          
          final inventory = Map<String, dynamic>.from(data['inventory'] as Map? ?? {});
          final stock = (inventory[cartItem.size] as num?)?.toInt() ?? 0;
          
          if (stock < cartItem.quantity) {
            throw StockException(
              stock == 0
                ? '${data['name']} (Size ${cartItem.size}) is out of stock'
                : '${data['name']}: Only $stock left in size ${cartItem.size}',
            );
          }
          
          final unitPrice = (data['price'] as num?)?.toDouble() ?? 0.0;
          final discountPct = (data['discountPct'] as num?)?.toInt() ?? 0;
          final finalPrice = unitPrice * (1 - discountPct / 100);
          final lineTotal = finalPrice * cartItem.quantity;
          
          updatedItems.add(OrderItemModel(
            productId: cartItem.productId,
            productName: data['name'] as String? ?? cartItem.productName,
            brand: data['brand'] as String? ?? cartItem.brand,
            imageUrl: data['thumbnailUrl'] as String? ?? cartItem.imageUrl,
            size: cartItem.size,
            color: cartItem.color,
            quantity: cartItem.quantity,
            unitPrice: unitPrice,
            discountPct: discountPct,
            finalPrice: finalPrice,
            lineTotal: lineTotal,
          ));
          newSubtotal += lineTotal;
        }
        
        // ALL Valid - WRITE product updates
        for (var i = 0; i < cartItems.length; i++) {
          final cartItem = cartItems[i];
          final productRef = productRefs[i];
          final data = snapshots[i].data()!;
          
          final inventory = Map<String, dynamic>.from(data['inventory'] as Map? ?? {});
          final currentStock = (inventory[cartItem.size] as num?)?.toInt() ?? 0;
          final currentTotal = (data['totalStock'] as num?)?.toInt() ?? 0;
          
          transaction.update(productRef, {
            'inventory.${cartItem.size}': currentStock - cartItem.quantity,
            'totalStock': currentTotal - cartItem.quantity,
            'soldCount': FieldValue.increment(cartItem.quantity),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        
        // WRITE Order Document
        final finalTotal = newSubtotal + order.shippingCost - order.discountAmount + order.taxAmount;
        final finalOrder = order.copyWith(
          items: updatedItems,
          subtotal: newSubtotal,
          total: finalTotal,
        );
        
        transaction.set(_ordersRef.doc(order.orderId), finalOrder.toFirestore());
        
        // WRITE Delete Cart Items
        final cartCollRef = firestore
            .collection(FirestoreConstants.users)
            .doc(userId)
            .collection(FirestoreConstants.cart);
            
        for (final item in cartItems) {
           transaction.delete(cartCollRef.doc(item.cartItemId));
        }
      });
    });
  }

  @override
  Stream<Either<Failure, List<OrderModel>>> watchUserOrders(String userId) {
    return safeFirestoreStream(() =>
      _ordersRef
          .where('userId', isEqualTo: userId)
          .orderBy('placedAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList())
    );
  }

  @override
  Future<Either<Failure, OrderModel>> getOrderById(String orderId) {
    return safeFirestoreCall(() async {
      final doc = await _ordersRef.doc(orderId).get();
      if (!doc.exists) {
        throw const NotFoundException('Order not found');
      }
      return OrderModel.fromFirestore(doc);
    });
  }

  @override
  Future<Either<Failure, List<OrderModel>>> getAllOrders({
    String? status,
    int limit = 20,
    dynamic lastDocument,
  }) {
    return safeFirestoreCall(() async {
      Query<Map<String, dynamic>> query = _ordersRef.orderBy('placedAt', descending: true);
      
      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }
      
      if (lastDocument != null && lastDocument is DocumentSnapshot) {
        query = query.startAfterDocument(lastDocument);
      }
      
      query = query.limit(limit);
      
      final snap = await query.get();
      return snap.docs.map(OrderModel.fromFirestore).toList();
    });
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? note,
    required String updatedBy,
  }) {
    return safeFirestoreCall(() async {
      final historyEntry = {
        'status': newStatus,
        'timestamp': FieldValue.serverTimestamp(),
        'note': note,
        'updatedBy': updatedBy,
      };
      
      await _ordersRef.doc(orderId).update({
        'status': newStatus,
        'statusHistory': FieldValue.arrayUnion([historyEntry]),
        'updatedAt': FieldValue.serverTimestamp(),
        if (newStatus == 'delivered') 'deliveredAt': FieldValue.serverTimestamp(),
      });
    });
  }
}


