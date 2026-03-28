import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:style_cart/app/app.dart';
import 'package:style_cart/core/config/firestore_config.dart';
import 'package:style_cart/core/errors/global_error_handler.dart';
import 'package:style_cart/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment Variables
  await dotenv.load(fileName: ".env");

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
