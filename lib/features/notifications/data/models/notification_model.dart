import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:style_cart/features/notifications/domain/entities/notification_entity.dart';
import 'package:uuid/uuid.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.notificationId,
    required super.userId,
    required super.title,
    required super.body,
    required super.type,
    required super.data,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromFCM({
    required String userId,
    required RemoteMessage message,
  }) {
    final msgData = message.data;
    return NotificationModel(
      notificationId: message.messageId ?? const Uuid().v4(),
      userId:    userId,
      title:     message.notification?.title ?? '',
      body:      message.notification?.body  ?? '',
      type: NotificationType.fromString(
        msgData['type'] as String? ?? 'system',
      ),
      data: NotificationData.fromMap(msgData),
      isRead:    false,
      createdAt: DateTime.now(),
    );
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return NotificationModel(
      notificationId: doc.id,
      userId:   d['userId']  as String? ?? '',
      title:    d['title']   as String? ?? '',
      body:     d['body']    as String? ?? '',
      type:     NotificationType.fromString(
        d['type'] as String? ?? 'system',
      ),
      data: NotificationData.fromMap(
        (d['data'] as Map<String, dynamic>?) ?? {},
      ),
      isRead:    d['isRead']   as bool?  ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId':         userId,
    'title':          title,
    'body':           body,
    'type':           type.value,
    'data':           data.toMap(),
    'isRead':         isRead,
    'createdAt':      FieldValue.serverTimestamp(),
  };

  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    NotificationData? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
