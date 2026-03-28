import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:stylecart/app/router/route_names.dart';
import 'package:stylecart/core/constants/firestore_constants.dart';
import 'package:stylecart/features/notifications/data/models/notification_model.dart';
import 'package:stylecart/features/notifications/domain/entities/notification_entity.dart';

class FCMService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  GoRouter? _router;

  static FCMService? _instance;

  FCMService._({
    required FirebaseMessaging messaging,
    required FirebaseFirestore firestore,
  })  : _messaging = messaging,
        _firestore = firestore;

  factory FCMService({
    required FirebaseMessaging messaging,
    required FirebaseFirestore firestore,
  }) {
    _instance ??= FCMService._(
      messaging: messaging,
      firestore: firestore,
    );
    return _instance!;
  }

  void setRouter(GoRouter router) {
    _router = router;
  }

  Future<void> initialize(String? userId) async {
    await requestPermission();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _setupAndroidChannel();

    if (userId != null) {
      await _fetchAndSaveToken(userId);
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        await _saveTokenToFirestore(currentUserId, newToken);
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      _handleForegroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      await Future<void>.delayed(const Duration(seconds: 1));
      _handleNotificationTap(initialMessage);
    }
  }

  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('FCM permission: ${settings.authorizationStatus}');
    return settings;
  }

  Future<void> _setupAndroidChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'stylecart_high_importance',
      'StyleCart Notifications',
      description: 'Order updates, promotions, and alerts',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  Future<String?> _fetchAndSaveToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(userId, token);
      }
      return token;
    } catch (e) {
      debugPrint('FCM token fetch error: $e');
      return null;
    }
  }

  Future<void> _saveTokenToFirestore(String userId, String token) async {
    try {
      await _firestore.collection(FirestoreConstants.users).doc(userId).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('FCM token saved for user: $userId');
    } catch (e) {
      debugPrint('FCM token save error: $e');
    }
  }

  Future<void> clearToken(String userId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .update({'fcmToken': null});
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('FCM token clear error: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM foreground: ${message.notification?.title}');
    _showLocalNotification(message);
    _saveNotificationToFirestore(message);
    _notificationStreamController.add(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final plugin = FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      'stylecart_high_importance',
      'StyleCart Notifications',
      channelDescription: 'Order updates and alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE8614A),
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await plugin.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final route = data['route'] as String?;

    if (route != null && route.isNotEmpty) {
      _router?.go(route);
    } else {
      final type = data['type'] as String? ?? '';
      final orderId = data['orderId'] as String?;

      if (type == 'order_update' && orderId != null) {
        _router?.go(RouteNames.orderTracking.replaceAll(':orderId', orderId));
      } else {
        _router?.go(RouteNames.home);
      }
    }
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final route = data['route'] as String?;
      final orderId = data['orderId'] as String?;
      final type = data['type'] as String? ?? '';

      if (route != null && route.isNotEmpty) {
        _router?.go(route);
      } else if (type == 'order_update' && orderId != null) {
        _router?.go(RouteNames.orderTracking.replaceAll(':orderId', orderId));
      }
    } catch (e) {
      debugPrint('Notification tap parse error: $e');
    }
  }

  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final notification = NotificationModel.fromFCM(
        userId: userId,
        message: message,
      );

      await _firestore
          .collection(FirestoreConstants.notifications)
          .doc(notification.notificationId)
          .set(notification.toFirestore());
    } catch (e) {
      debugPrint('Save notification error: $e');
    }
  }

  final _notificationStreamController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get notificationStream =>
      _notificationStreamController.stream;

  void dispose() {
    _notificationStreamController.close();
  }
}
