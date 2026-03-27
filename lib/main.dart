import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:style_cart/features/notifications/data/services/fcm_background_handler.dart';

import 'package:style_cart/app/app.dart';
import 'package:style_cart/core/config/app_config.dart';
import 'package:style_cart/core/errors/global_error_handler.dart';
import 'package:style_cart/core/security/sensitive_data_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Global Error Handler & Security
  await GlobalErrorHandler.initialize();
  SensitiveDataGuard.setupDebugLogging();

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Load .env before Firebase initialization
  await dotenv.load();
  AppConfig.validateEnvironment();

  // Initialize Firebase - handle duplicate app error
  // Use try-catch to handle race condition on hot reload
  try {
    await Firebase.initializeApp(options: _buildFirebaseOptions());
  } on FirebaseException {
    // Ignore duplicate app error - app already exists
  } catch (e) {
    // Re-throw any other errors
  }

  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set full screen mode - hide status bar and navigation
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: StyleCartApp()));
}

FirebaseOptions _buildFirebaseOptions() {
  return FirebaseOptions(
    apiKey: AppConfig.firebaseWebApiKey,
    projectId: AppConfig.firebaseProjectId,
    storageBucket: AppConfig.firebaseStorageBucket,
    messagingSenderId: AppConfig.firebaseMessagingSenderId,
    appId: AppConfig.firebaseAppId,
  );
}
