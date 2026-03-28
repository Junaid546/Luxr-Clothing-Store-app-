import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Single source of truth for ALL app configuration.
// Reads from .env with validation.
// NEVER hardcode values — always read from here.

class AppConfig {
  AppConfig._();

  // ── Firebase Config ────────────────────────────────
  static String get firebaseWebApiKey => _require('FIREBASE_WEB_API_KEY');

  static String get firebaseProjectId => _require('FIREBASE_PROJECT_ID');

  static String get firebaseStorageBucket =>
      _require('FIREBASE_STORAGE_BUCKET');

  static String get firebaseMessagingSenderId =>
      _require('FIREBASE_MESSAGING_SENDER_ID');

  static String get firebaseAppId => _require('FIREBASE_APP_ID');

  // ── Business Config ────────────────────────────────
  static int get lowStockThreshold =>
      int.parse(dotenv.env['LOW_STOCK_THRESHOLD'] ?? '5');

  static double get freeShippingThreshold => double.parse(
        dotenv.env['FREE_SHIPPING_THRESHOLD'] ?? '100',
      );

  static double get expressShippingCost => double.parse(
        dotenv.env['EXPRESS_SHIPPING_COST'] ?? '25',
      );

  // ── Environment detection ──────────────────────────
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => kDebugMode;

  // ── Validate all required env vars on startup ──────
  // Call this in main() after dotenv.load()
  static void validateEnvironment() {
    final required = [
      'FIREBASE_WEB_API_KEY',
      'FIREBASE_PROJECT_ID',
      'FIREBASE_STORAGE_BUCKET',
      'FIREBASE_MESSAGING_SENDER_ID',
      'FIREBASE_APP_ID',
    ];

    final missing = required
        .where(
          (key) => dotenv.env[key]?.isEmpty ?? true,
        )
        .toList();

    if (missing.isNotEmpty) {
      throw Exception(
        'Missing required environment variables: ${missing.join(', ')}\n'
        'Check your .env file.',
      );
    }

    // Validate format of critical values (only basic check to avoid blocking dev placeholders)
    final projectId = dotenv.env['FIREBASE_PROJECT_ID']!;
    if (projectId.contains(' ') || projectId.length < 4) {
      throw Exception(
        'Invalid FIREBASE_PROJECT_ID format in .env file. '
        'Please ensure it contains your actual Firebase Project ID.',
      );
    }

    if (kDebugMode) {
      debugPrint('✓ Environment variables validated');
      debugPrint('  Project: $projectId');
      debugPrint(
        '  Mode: ${isProduction ? "PRODUCTION" : "DEV"}',
      );
    }
  }

  // ── Private helper ─────────────────────────────────
  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception(
        'Required environment variable $key is missing. Check your .env file.',
      );
    }
    return value;
  }
}
