import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylecart/app/app.dart';
import 'package:stylecart/core/config/environment.dart';
import 'package:stylecart/core/config/firestore_config.dart';
import 'package:stylecart/core/errors/global_error_handler.dart';
import 'package:stylecart/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment Variables
  await dotenv.load(fileName: ".env");

  // Set Environment based on build mode
  EnvironmentConfig.setEnvironment(
    EnvironmentConfig.fromBuildMode(),
  );

  // Initialize Firebase

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Initialize Global Error Handling ────────
  await GlobalErrorHandler.initialize();

  // ── Configure Firestore for performance ────
  await FirestoreConfig.configure();

  runApp(
    const ProviderScope(
      child: StyleCartApp(),
    ),
  );
}
