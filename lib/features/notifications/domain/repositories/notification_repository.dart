import 'package:dartz/dartz.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/notifications/domain/entities/notification_entity.dart';

abstract interface class NotificationRepository {
  /// Stream of notifications for a specific user
  Stream<List<NotificationEntity>> watchNotifications(String userId);

  /// Mark a single notification as read
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// Mark all notifications for a user as read
  Future<Either<Failure, void>> markAllAsRead(String userId);

  /// Delete a notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Get unread notification count
  Stream<int> watchUnreadCount(String userId);

  /// Clear all notifications for a user
  Future<Either<Failure, void>> clearAll(String userId);
}
