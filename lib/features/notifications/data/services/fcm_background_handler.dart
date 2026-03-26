import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/features/notifications/data/models/notification_model.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure dotenv is loaded for Firebase options if needed
  // But usually, it's better to use static options for background initialization
  // to avoid disk I/O issues in isolates.

  try {
    await Firebase.initializeApp();
  } catch (e) {
    // If it fails (e.g. options needed), we might need to load dotenv
    try {
      await dotenv.load();
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey:            dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
          projectId:         dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
          storageBucket:     dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
          messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
          appId:             dotenv.env['FIREBASE_APP_ID'] ?? '',
        ),
      );
    } catch (e2) {
      debugPrint('FCM background init failed: $e2');
      return;
    }
  }

  debugPrint('FCM background handler: ${message.notification?.title}');

  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final firestore = FirebaseFirestore.instance;
    final notification = NotificationModel.fromFCM(
      userId: userId,
      message: message,
    );

    await firestore
        .collection(FirestoreConstants.notifications)
        .doc(notification.notificationId)
        .set(notification.toFirestore());

  } catch (e) {
    debugPrint('Background FCM save error: $e');
  }
}
