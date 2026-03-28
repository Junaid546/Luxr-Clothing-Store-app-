import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stylecart/features/auth/data/providers/auth_providers.dart';
import 'package:stylecart/features/notifications/data/models/notification_model.dart';
import 'package:stylecart/features/notifications/data/providers/notification_providers.dart';
import 'package:stylecart/features/notifications/domain/entities/notification_entity.dart';

part 'notification_notifier.freezed.dart';
part 'notification_notifier.g.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default([]) List<NotificationEntity> notifications,
    @Default(0) int unreadCount,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasMore,
    @Default(false) bool hasError,
    @Default('') String errorMessage,
    @Default('all') String activeFilter,
    // 'all' | notification type values
    Object? lastDocument,
  }) = _NotificationState;
}

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _unreadCountSubscription;
  StreamSubscription? _fcmSubscription;

  @override
  NotificationState build() {
    final userId = ref.watch(currentUserProvider)?.uid;
    if (userId != null) {
      // Small delay to ensure subscriptions are handled après build
      Future.microtask(() {
        _watchNotifications(userId);
        _watchUnreadCount(userId);
        _listenToFCMStream();
      });
    }

    ref.onDispose(_disposeAll);
    return const NotificationState(isLoading: true);
  }

  // ── Watch Firestore notifications ─────────────────
  void _watchNotifications(String userId) {
    _notificationSubscription?.cancel();
    _notificationSubscription = ref
        .read(notificationRepositoryProvider)
        .watchNotifications(userId)
        .listen((notifications) {
      final filtered = _applyFilter(
        notifications,
        state.activeFilter,
      );
      state = state.copyWith(
        isLoading: false,
        notifications: filtered,
        hasMore: notifications.length >= 50,
      );
    }, onError: (error) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: error.toString(),
      );
    });
  }

  // ── Watch unread count ─────────────────────────────
  void _watchUnreadCount(String userId) {
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = ref
        .watch(notificationRepositoryProvider)
        .watchUnreadCount(userId)
        .listen((count) {
      state = state.copyWith(unreadCount: count);
    });
  }

  // ── Listen to FCM stream (foreground messages) ────
  // This adds NEW incoming messages to the list
  // without waiting for Firestore snapshot
  void _listenToFCMStream() {
    _fcmSubscription?.cancel();
    final fcmService = ref.read(fcmServiceProvider);
    _fcmSubscription = fcmService.notificationStream.listen((message) {
      final userId = ref.read(currentUserProvider)?.uid;
      if (userId == null) return;

      // Create a temporary notification entity
      final newNotification = NotificationModel.fromFCM(
        userId: userId,
        message: message,
      );

      // Prepend to current list (newest first) if it matches filter or filter is 'all'
      if (state.activeFilter == 'all' ||
          newNotification.type.value == state.activeFilter) {
        final updatedList = [
          newNotification,
          ...state.notifications,
        ];

        state = state.copyWith(
          notifications: updatedList,
          unreadCount: state.unreadCount + 1,
        );
      } else {
        // Just increment count if filtered out
        state = state.copyWith(
          unreadCount: state.unreadCount + 1,
        );
      }
    });
  }

  // ── Filter notifications by type ──────────────────
  List<NotificationEntity> _applyFilter(
    List<NotificationEntity> all,
    String filter,
  ) {
    if (filter == 'all') return all;
    return all.where((n) => n.type.value == filter).toList();
  }

  void setFilter(String filter) {
    state = state.copyWith(
      activeFilter: filter,
      isLoading: true,
    );
    final userId = ref.read(currentUserProvider)?.uid;
    if (userId != null) _watchNotifications(userId);
  }

  // ── Mark single as read ────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    // Optimistic update: update UI immediately
    final updatedList = state.notifications.map((n) {
      if (n.notificationId == notificationId && !n.isRead) {
        return (n as NotificationModel).copyWith(
          isRead: true,
        );
      }
      return n;
    }).toList();

    final wasUnread = state.notifications.any(
      (n) => n.notificationId == notificationId && !n.isRead,
    );

    if (wasUnread) {
      state = state.copyWith(
        notifications: updatedList,
        unreadCount: (state.unreadCount - 1).clamp(0, 999),
      );
      // Persist to Firestore
      await ref.read(notificationRepositoryProvider).markAsRead(notificationId);
    }
  }

  // ── Mark all as read ───────────────────────────────
  Future<void> markAllAsRead() async {
    final userId = ref.read(currentUserProvider)?.uid;
    if (userId == null) return;

    // Optimistic update
    final updatedList = state.notifications.map((n) {
      if (n is NotificationModel) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    state = state.copyWith(
      notifications: updatedList,
      unreadCount: 0,
    );

    await ref.read(notificationRepositoryProvider).markAllAsRead(userId);
  }

  // ── Delete notification ────────────────────────────
  Future<void> deleteNotification(
    String notificationId,
  ) async {
    // Optimistic remove from list
    final updatedList = state.notifications
        .where((n) => n.notificationId != notificationId)
        .toList();

    final wasUnread = state.notifications
        .any((n) => n.notificationId == notificationId && !n.isRead);

    state = state.copyWith(
      notifications: updatedList,
      unreadCount:
          wasUnread ? (state.unreadCount - 1).clamp(0, 999) : state.unreadCount,
    );

    await ref
        .read(notificationRepositoryProvider)
        .deleteNotification(notificationId);
  }

  // ── Clear all notifications ────────────────────────
  Future<void> clearAll() async {
    final userId = ref.read(currentUserProvider)?.uid;
    if (userId == null) return;

    state = state.copyWith(
      notifications: [],
      unreadCount: 0,
    );

    await ref.read(notificationRepositoryProvider).clearAll(userId);
  }

  void _disposeAll() {
    _notificationSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    _fcmSubscription?.cancel();
  }
}

// Convenience provider for unread count badge
@riverpod
int notificationUnreadCount(NotificationUnreadCountRef ref) {
  return ref.watch(
    notificationNotifierProvider.select((s) => s.unreadCount),
  );
}
