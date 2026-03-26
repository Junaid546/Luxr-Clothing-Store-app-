import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:style_cart/app/theme/app_colors.dart';

class NotificationEntity extends Equatable {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationData data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  bool get hasRoute => data.route != null;

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return DateFormat('MMM dd').format(createdAt);
  }

  @override
  List<Object?> get props => [
    notificationId, isRead, createdAt,
  ];
}

enum NotificationType {
  orderUpdate,
  promotion,
  newArrival,
  system,
  lowStock;

  String get value => switch (this) {
    NotificationType.orderUpdate => 'order_update',
    NotificationType.promotion   => 'promotion',
    NotificationType.newArrival  => 'new_arrival',
    NotificationType.system      => 'system',
    NotificationType.lowStock    => 'low_stock',
  };

  static NotificationType fromString(String value) =>
      switch (value) {
        'order_update' => NotificationType.orderUpdate,
        'promotion'    => NotificationType.promotion,
        'new_arrival'  => NotificationType.newArrival,
        'low_stock'    => NotificationType.lowStock,
        _              => NotificationType.system,
      };

  String get displayTitle => switch (this) {
    NotificationType.orderUpdate => 'Order Update',
    NotificationType.promotion   => 'Promotion',
    NotificationType.newArrival  => 'New Arrival',
    NotificationType.system      => 'System',
    NotificationType.lowStock    => 'Low Stock Alert',
  };

  IconData get icon => switch (this) {
    NotificationType.orderUpdate => Icons.local_shipping_outlined,
    NotificationType.promotion   => Icons.local_offer_outlined,
    NotificationType.newArrival  => Icons.new_releases_outlined,
    NotificationType.system      => Icons.info_outline,
    NotificationType.lowStock    => Icons.warning_amber_outlined,
  };

  Color get color => switch (this) {
    NotificationType.orderUpdate => AppColors.primary,
    NotificationType.promotion   => AppColors.gold,
    NotificationType.newArrival  => AppColors.successTeal,
    NotificationType.system      => AppColors.textSecondary,
    NotificationType.lowStock    => AppColors.warning,
  };
}

class NotificationData extends Equatable {
  final String? orderId;
  final String? productId;
  final String? route;
  final Map<String, String> extra;

  const NotificationData({
    this.orderId,
    this.productId,
    this.route,
    this.extra = const {},
  });

  factory NotificationData.fromMap(Map<String, dynamic> map) => NotificationData(
    orderId:   map['orderId'] as String?,
    productId: map['productId'] as String?,
    route:     map['route'] as String?,
    extra: Map<String, String>.from(
      (map['extra'] as Map?)?.cast<String, String>() ?? {},
    ),
  );

  Map<String, dynamic> toMap() => {
    'orderId':   orderId,
    'productId': productId,
    'route':     route,
    'extra':     extra,
  };

  @override
  List<Object?> get props => [orderId, productId, route];
}
