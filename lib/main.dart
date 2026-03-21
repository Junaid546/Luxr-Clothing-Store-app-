import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:style_cart/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env before Firebase initialization
  await dotenv.load();

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
    apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? 'demo_key',
    projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'demo_project',
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'demo_bucket',
    messagingSenderId:
        dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? 'demo_sender',
    appId: dotenv.env['FIREBASE_APP_ID'] ?? 'demo_app_id',
  );
}
