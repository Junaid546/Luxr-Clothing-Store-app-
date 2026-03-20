import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env before Firebase initialization
  await dotenv.load(fileName: '.env');

  // Initialize Firebase with options from .env
  await Firebase.initializeApp(options: _buildFirebaseOptions());

  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
