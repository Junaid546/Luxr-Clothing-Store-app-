import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';

class OrderEntity extends Equatable {

  const OrderEntity({
    required this.orderId,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.discountAmount,
    required this.taxAmount,
    required this.total,
    required this.shippingMethod,
    required this.shippingAddress,
    required this.estimatedDelivery,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status, required this.statusHistory, required this.placedAt, required this.updatedAt, this.transactionId,
    this.courier,
    this.deliveredAt,
  });
  final String orderId;
  final String userId;
  final String userEmail;
  final String userName;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double shippingCost;
  final double discountAmount;
  final double taxAmount;
  final double total;
  final String shippingMethod;
  final ShippingAddressEntity shippingAddress;
  final EstimatedDeliveryEntity estimatedDelivery;
  final String paymentMethod;
  final String paymentStatus;
  final String? transactionId;
  final String status;
  final List<StatusHistoryEntity> statusHistory;
  final CourierEntity? courier;
  final DateTime placedAt;
  final DateTime updatedAt;
  final DateTime? deliveredAt;

  // ── Business Logic ────────────────────────────────

  bool get isCancellable => [
    OrderStatus.pending,
    OrderStatus.confirmed,
  ].contains(status);

  bool get isReturnable =>
      status == OrderStatus.delivered &&
      deliveredAt != null &&
      DateTime.now().difference(deliveredAt!).inDays <= 7;

  bool get isActive => ![
    OrderStatus.delivered,
    OrderStatus.cancelled,
    OrderStatus.returned,
  ].contains(status);

  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isShipped =>
      status == OrderStatus.shipped ||
      status == OrderStatus.outForDelivery;

  int get totalItems =>
      items.fold(0, (sum, i) => sum + i.quantity);

  double get totalSavings => items.fold(
    0,
    (sum, item) => sum +
        ((item.unitPrice - item.finalPrice) * item.quantity),
  );

  // Current status index for timeline UI (0-based)
  int get statusIndex => switch (status) {
    OrderStatus.pending          => 0,
    OrderStatus.confirmed        => 1,
    OrderStatus.processing       => 2,
    OrderStatus.packed           => 2,
    OrderStatus.shipped          => 3,
    OrderStatus.outForDelivery   => 3,
    OrderStatus.delivered        => 4,
    _                            => 0,
  };

  String get statusDisplay => switch (status) {
    OrderStatus.pending          => 'Order Placed',
    OrderStatus.confirmed        => 'Confirmed',
    OrderStatus.processing       => 'Processing',
    OrderStatus.packed           => 'Packed',
    OrderStatus.shipped          => 'Shipped',
    OrderStatus.outForDelivery   => 'Out for Delivery',
    OrderStatus.delivered        => 'Delivered',
    OrderStatus.cancelled        => 'Cancelled',
    OrderStatus.returnRequested  => 'Return Requested',
    OrderStatus.returned         => 'Returned',
    _                            => status,
  };

  // Next status in lifecycle
  String? get nextStatus => switch (status) {
    OrderStatus.pending        => OrderStatus.confirmed,
    OrderStatus.confirmed      => OrderStatus.processing,
    OrderStatus.processing     => OrderStatus.packed,
    OrderStatus.packed         => OrderStatus.shipped,
    OrderStatus.shipped        => OrderStatus.outForDelivery,
    OrderStatus.outForDelivery => OrderStatus.delivered,
    _                          => null, // terminal states
  };

  @override
  List<Object?> get props => [
    orderId, status, userId, updatedAt,
  ];
}

class OrderItemEntity extends Equatable {

  const OrderItemEntity({
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

  bool get hasDiscount => discountPct > 0;
  double get savings =>
      (unitPrice - finalPrice) * quantity;

  @override
  List<Object> get props => [productId, size, color];
}

class StatusHistoryEntity extends Equatable {

  const StatusHistoryEntity({
    required this.status,
    required this.timestamp,
    required this.updatedBy, this.note,
  });
  final String status;
  final DateTime timestamp;
  final String? note;
  final String updatedBy;

  String get statusDisplay => switch (status) {
    OrderStatus.pending          => 'Order Placed',
    OrderStatus.confirmed        => 'Order Confirmed',
    OrderStatus.processing       => 'Processing',
    OrderStatus.packed           => 'Packed',
    OrderStatus.shipped          => 'Shipped',
    OrderStatus.outForDelivery   => 'Out for Delivery',
    OrderStatus.delivered        => 'Delivered',
    OrderStatus.cancelled        => 'Cancelled',
    OrderStatus.returnRequested  => 'Return Requested',
    OrderStatus.returned         => 'Returned',
    _                            => status,
  };

  @override
  List<Object?> get props => [status, timestamp];
}

class CourierEntity extends Equatable {

  const CourierEntity({
    this.name,
    this.trackingNumber,
    this.estimatedTime,
    this.latitude,
    this.longitude,
  });
  final String? name;
  final String? trackingNumber;
  final String? estimatedTime;
  final double? latitude;
  final double? longitude;

  @override
  List<Object?> get props => [name, trackingNumber];
}

class ShippingAddressEntity extends Equatable {

  const ShippingAddressEntity({
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  String get singleLine =>
      '$street, $city, $state $zipCode';

  String get fullFormatted =>
      '$fullName\n$street\n$city, $state $zipCode\n$country';

  @override
  List<Object> get props => [street, city, zipCode];
}

class EstimatedDeliveryEntity extends Equatable {

  const EstimatedDeliveryEntity({
    required this.from,
    required this.to,
  });
  final DateTime from;
  final DateTime to;

  String get displayRange {
    final formatter = DateFormat('MMM dd');
    return '${formatter.format(from).toUpperCase()}'
           ' - '
           '${formatter.format(to).toUpperCase()}';
  }

  bool get isOverdue =>
      DateTime.now().isAfter(to) && !isToday;

  bool get isToday {
    final now = DateTime.now();
    return to.year == now.year &&
           to.month == now.month &&
           to.day == now.day;
  }

  @override
  List<Object> get props => [from, to];
}
