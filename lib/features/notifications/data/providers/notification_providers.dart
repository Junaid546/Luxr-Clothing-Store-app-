import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylecart/core/providers/firebase_providers.dart';
import 'package:stylecart/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:stylecart/features/notifications/data/services/fcm_service.dart';
import 'package:stylecart/features/notifications/domain/entities/notification_entity.dart';
import 'package:stylecart/features/notifications/domain/repositories/notification_repository.dart';
import 'package:stylecart/app/router/app_router.dart';
import 'package:stylecart/features/auth/presentation/providers/auth_state_notifier.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return NotificationRepositoryImpl(firestore);
});

/// Tracks if the notification permission dialog has been shown in the current session.
final notificationPermissionDialogShownProvider =
    StateProvider<bool>((ref) => false);

/// Tracks if the "Welcome" badge for new accounts has been shown/dismissed.
final welcomeBadgeDismissedProvider = StateProvider<bool>((ref) => false);

final fcmServiceProvider = Provider<FCMService>((ref) {
  final messaging = ref.watch(firebaseMessagingProvider);
  final firestore = ref.watch(firestoreProvider);
  return FCMService(
    messaging: messaging,
    firestore: firestore,
  );
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final isDismissed = ref.watch(welcomeBadgeDismissedProvider);

  if (authState is AuthAuthenticated) {
    // Logic: Only show badge if account is "new" (created in last 5 minutes)
    // and hasn't been dismissed in this session.
    final user = authState.user;
    final now = DateTime.now();
    final isNewAccount = now.difference(user.createdAt).inMinutes < 5;

    if (isNewAccount && !isDismissed) {
      return Stream<int>.value(1);
    }
  }

  // Per user request: "otherwise not" - do not show for any other reason.
  return Stream<int>.value(0);
});

final notificationsStreamProvider =
    StreamProvider.autoDispose<List<NotificationEntity>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  final authState = ref.watch(authNotifierProvider);

  if (authState is AuthAuthenticated) {
    return repository.watchNotifications(authState.user.uid);
  }
  return Stream<List<NotificationEntity>>.value([]);
});

final fcmInitializerProvider = Provider<void>((ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState is AuthAuthenticated) {
    final fcmService = ref.read(fcmServiceProvider);
    final router = ref.read(appRouterProvider);

    // Set router first to break circular dependency at creation time
    fcmService.setRouter(router);
    fcmService.initialize(authState.user.uid);
  }
});
