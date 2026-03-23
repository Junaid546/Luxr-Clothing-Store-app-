// ignore_for_file: public_member_api_docs, sort_constructors_first, always_put_required_named_parameters_first, invalid_annotation_target, sort_unnamed_constructors_first, lines_longer_than_80_chars, document_ignores
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';

part 'order_model.freezed.dart';

@freezed
class OrderModel with _$OrderModel {
  const OrderModel._();

  const factory OrderModel({
    required String orderId,
    required String userId,
    required String userEmail,
    required String userName,
    required List<OrderItemModel> items,
    required double subtotal,
    required double shippingCost,
    required double discountAmount,
    required double taxAmount,
    required double total,
    required String shippingMethod,
    required ShippingAddressModel shippingAddress,
    required EstimatedDeliveryModel estimatedDelivery,
    required String paymentMethod,
    required String paymentStatus,
    String? transactionId,
    required String status,
    required List<StatusHistoryEntry> statusHistory,
    CourierModel? courier,
    required DateTime placedAt,
    required DateTime updatedAt,
    DateTime? deliveredAt,
  }) = _OrderModel;

  // Ã¢â€â‚¬Ã¢â€â‚¬ Computed helpers Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  bool get isCancellable => [
    OrderStatus.pending,
    OrderStatus.confirmed,
  ].contains(status);

  bool get isReturnable => status == OrderStatus.delivered;

  bool get isActive => ![
    OrderStatus.delivered,
    OrderStatus.cancelled,
    OrderStatus.returned,
  ].contains(status);

  int get totalItems => items.fold(0, (acc, i) => acc + i.quantity);

  // Ã¢â€â‚¬Ã¢â€â‚¬ Status display helpers Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  String get statusDisplay => switch (status) {
    'pending'          => 'Order Placed',
    'confirmed'        => 'Confirmed',
    'processing'       => 'Processing',
    'packed'           => 'Packed',
    'shipped'          => 'Shipped',
    'out_for_delivery' => 'Out for Delivery',
    'delivered'        => 'Delivered',
    'cancelled'        => 'Cancelled',
    'return_requested' => 'Return Requested',
    'returned'         => 'Returned',
    _                  => status,
  };

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? const <String, dynamic>{};

    final rawItems = d['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((i) => OrderItemModel.fromMap(
              i as Map<String, dynamic>))
        .toList();

    final rawHistory = 
        d['statusHistory'] as List<dynamic>? ?? [];
    final history = rawHistory
        .map((h) => StatusHistoryEntry.fromMap(
              h as Map<String, dynamic>))
        .toList();

    return OrderModel(
      orderId:          doc.id,
      userId:           d['userId'] as String? ?? '',
      userEmail:        d['userEmail'] as String? ?? '',
      userName:         d['userName'] as String? ?? '',
      items:            items,
      subtotal:         (d['subtotal'] as num?)?.toDouble() 
                          ?? 0.0,
      shippingCost:     (d['shippingCost'] as num?)?.toDouble() 
                          ?? 0.0,
      discountAmount:   (d['discountAmount'] as num?)
                          ?.toDouble() ?? 0.0,
      taxAmount:        (d['taxAmount'] as num?)?.toDouble() 
                          ?? 0.0,
      total:            (d['total'] as num?)?.toDouble() ?? 0.0,
      shippingMethod:   d['shippingMethod'] as String? 
                          ?? 'standard',
      shippingAddress:  ShippingAddressModel.fromMap(
                          d['shippingAddress'] as 
                          Map<String, dynamic>? ?? {}),
      estimatedDelivery: EstimatedDeliveryModel.fromMap(
                          d['estimatedDelivery'] as 
                          Map<String, dynamic>? ?? {}),
      paymentMethod:    d['paymentMethod'] as String? ?? 'cod',
      paymentStatus:    d['paymentStatus'] as String? 
                          ?? 'pending',
      transactionId:    d['transactionId'] as String?,
      status:           d['status'] as String? ?? 'pending',
      statusHistory:    history,
      courier:          d['courier'] != null
                          ? CourierModel.fromMap(
                              d['courier'] as 
                              Map<String, dynamic>)
                          : null,
      placedAt:         (d['placedAt'] as Timestamp?)
                          ?.toDate() ?? DateTime.now(),
      updatedAt:        (d['updatedAt'] as Timestamp?)
                          ?.toDate() ?? DateTime.now(),
      deliveredAt:      (d['deliveredAt'] as Timestamp?)
                          ?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'orderId':           orderId,
    'userId':            userId,
    'userEmail':         userEmail,
    'userName':          userName,
    'items':             items.map((i) => i.toMap()).toList(),
    'subtotal':          subtotal,
    'shippingCost':      shippingCost,
    'discountAmount':    discountAmount,
    'taxAmount':         taxAmount,
    'total':             total,
    'shippingMethod':    shippingMethod,
    'shippingAddress':   shippingAddress.toMap(),
    'estimatedDelivery': estimatedDelivery.toMap(),
    'paymentMethod':     paymentMethod,
    'paymentStatus':     paymentStatus,
    'transactionId':     transactionId,
    'status':            status,
    'statusHistory':     statusHistory
                           .map((h) => h.toMap()).toList(),
    'courier':           courier?.toMap(),
    'placedAt':          FieldValue.serverTimestamp(),
    'updatedAt':         FieldValue.serverTimestamp(),
    'deliveredAt':       deliveredAt != null
                           ? Timestamp.fromDate(deliveredAt!)
                           : null,
  };
}

// Ã¢â€â‚¬Ã¢â€â‚¬ OrderItemModel Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class OrderItemModel extends Equatable {
  final String productId;
  final String productName;
  final String brand;
  final String imageUrl;
  final String size;
  final String color;
  final int quantity;
  final double unitPrice;
  final int discountPct;
  final double finalPrice;
  final double lineTotal;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.brand,
    required this.imageUrl,
    required this.size,
    required this.color,
    required this.quantity,
    required this.unitPrice,
    required this.discountPct,
    required this.finalPrice,
    required this.lineTotal,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> m) =>
      OrderItemModel(
        productId:   m['productId']   as String? ?? '',
        productName: m['productName'] as String? ?? '',
        brand:       m['brand']       as String? ?? '',
        imageUrl:    m['imageUrl']    as String? ?? '',
        size:        m['size']        as String? ?? '',
        color:       m['color']       as String? ?? '',
        quantity:    (m['quantity']   as num?)?.toInt() ?? 1,
        unitPrice:   (m['unitPrice']  as num?)?.toDouble() ?? 0,
        discountPct: (m['discountPct'] as num?)?.toInt() ?? 0,
        finalPrice:  (m['finalPrice'] as num?)?.toDouble() ?? 0,
        lineTotal:   (m['lineTotal']  as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'productId':   productId,
    'productName': productName,
    'brand':       brand,
    'imageUrl':    imageUrl,
    'size':        size,
    'color':       color,
    'quantity':    quantity,
    'unitPrice':   unitPrice,
    'discountPct': discountPct,
    'finalPrice':  finalPrice,
    'lineTotal':   lineTotal,
  };

  @override
  List<Object> get props => [productId, size, color];
}

// Ã¢â€â‚¬Ã¢â€â‚¬ ShippingAddressModel Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class ShippingAddressModel extends Equatable {
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  const ShippingAddressModel({
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  factory ShippingAddressModel.fromMap(
      Map<String, dynamic> m) => ShippingAddressModel(
    fullName: m['fullName'] as String? ?? '',
    phone:    m['phone']    as String? ?? '',
    street:   m['street']   as String? ?? '',
    city:     m['city']     as String? ?? '',
    state:    m['state']    as String? ?? '',
    zipCode:  m['zipCode']  as String? ?? '',
    country:  m['country']  as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'fullName': fullName, 'phone': phone,
    'street': street,     'city': city,
    'state': state,       'zipCode': zipCode,
    'country': country,
  };

  String get formatted =>
    '$street, $city, $state $zipCode, $country';

  @override
  List<Object> get props => 
    [street, city, state, zipCode];
}

// Ã¢â€â‚¬Ã¢â€â‚¬ EstimatedDeliveryModel Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class EstimatedDeliveryModel extends Equatable {
  final DateTime from;
  final DateTime to;
  
  const EstimatedDeliveryModel({
    required this.from, required this.to,
  });

  factory EstimatedDeliveryModel.fromMap(
      Map<String, dynamic> m) => EstimatedDeliveryModel(
    from: (m['from'] as Timestamp?)?.toDate() ?? DateTime.now(),
    to:   (m['to']   as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'from': Timestamp.fromDate(from),
    'to':   Timestamp.fromDate(to),
  };

  // Compute delivery window from order placement
  factory EstimatedDeliveryModel.forMethod(String method) {
    final now = DateTime.now();
    if (method == ShippingMethod.express) {
      return EstimatedDeliveryModel(
        from: now.add(const Duration(days: 1)),
        to:   now.add(const Duration(days: 1)),
      );
    }
    return EstimatedDeliveryModel(
      from: now.add(const Duration(days: 3)),
      to:   now.add(const Duration(days: 5)),
    );
  }

  @override
  List<Object> get props => [from, to];
}

// Ã¢â€â‚¬Ã¢â€â‚¬ StatusHistoryEntry Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class StatusHistoryEntry extends Equatable {
  final String status;
  final DateTime timestamp;
  final String? note;
  final String updatedBy;

  const StatusHistoryEntry({
    required this.status,
    required this.timestamp,
    this.note,
    required this.updatedBy,
  });

  factory StatusHistoryEntry.fromMap(
      Map<String, dynamic> m) => StatusHistoryEntry(
    status:    m['status']    as String? ?? '',
    timestamp: (m['timestamp'] as Timestamp?)?.toDate()
                 ?? DateTime.now(),
    note:      m['note']      as String?,
    updatedBy: m['updatedBy'] as String? ?? 'system',
  );

  Map<String, dynamic> toMap() => {
    'status':    status,
    'timestamp': FieldValue.serverTimestamp(),
    'note':      note,
    'updatedBy': updatedBy,
  };

  @override
  List<Object?> get props => [status, timestamp];
}

// Ã¢â€â‚¬Ã¢â€â‚¬ CourierModel Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class CourierModel extends Equatable {
  final String? name;
  final String? trackingNumber;
  final String? estimatedTime;

  const CourierModel({this.name, this.trackingNumber,
                      this.estimatedTime});

  factory CourierModel.fromMap(Map<String, dynamic> m) =>
      CourierModel(
        name:          m['name'] as String?,
        trackingNumber:m['trackingNumber'] as String?,
        estimatedTime: m['estimatedTime'] as String?,
      );

  Map<String, dynamic> toMap() => {
    'name': name, 'trackingNumber': trackingNumber,
    'estimatedTime': estimatedTime,
  };

  @override
  List<Object?> get props => [name, trackingNumber];
}



