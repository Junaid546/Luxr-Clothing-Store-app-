import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:style_cart/core/providers/firebase_providers.dart';
import 'package:style_cart/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:style_cart/features/notifications/data/services/fcm_service.dart';
import 'package:style_cart/features/notifications/domain/entities/notification_entity.dart';
import 'package:style_cart/features/notifications/domain/repositories/notification_repository.dart';
import 'package:style_cart/app/router/app_router.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return NotificationRepositoryImpl(firestore);
});

final fcmServiceProvider = Provider<FCMService>((ref) {
  final messaging = ref.watch(firebaseMessagingProvider);
  final firestore = ref.watch(firestoreProvider);
  final router = ref.watch(appRouterProvider);

  return FCMService(
    messaging: messaging,
    firestore: firestore,
    router: router,
  );
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  final authState = ref.watch(authNotifierProvider);

  if (authState is AuthAuthenticated) {
    return repository.watchUnreadCount(authState.user.uid);
  }
  return Stream<int>.value(0);
});

final notificationsStreamProvider = StreamProvider.autoDispose<List<NotificationEntity>>((ref) {
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
    ref.read(fcmServiceProvider).initialize(authState.user.uid);
  }
});
