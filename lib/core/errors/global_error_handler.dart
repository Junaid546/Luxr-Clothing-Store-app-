import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:style_cart/core/security/sensitive_data_guard.dart';

// Centralized error handling for the entire app.
// Catches: Flutter framework errors, Dart errors,
//          Firebase errors, network errors.
// In DEBUG: prints full stack traces.
// In RELEASE: logs to crash reporting (Firebase Crashlytics).

class GlobalErrorHandler {
  GlobalErrorHandler._();

  static bool _initialized = false;

  // ── Initialize — call in main() ────────────────────
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // 1. Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        // Print full error in debug
        FlutterError.presentError(details);
      } else {
        // Log to Crashlytics in release
        _logToFirebase(
          details.exception,
          details.stack ?? StackTrace.empty,
          context: details.context?.toString(),
        );
      }
    };

    // 2. Dart async errors (not caught by Flutter)
    PlatformDispatcher.instance.onError = (
      Object error,
      StackTrace stack,
    ) {
      if (kDebugMode) {
        debugPrint('═══ UNHANDLED DART ERROR ═══');
        debugPrint(error.toString());
        debugPrint(stack.toString());
        debugPrint('═══════════════════════════');
      } else {
        _logToFirebase(error, stack, isFatal: true);
      }
      return true; // Mark as handled
    };

    // 3. Firebase Crashlytics setup (release only)
    if (kReleaseMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      // Pass Flutter errors to Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    }

    debugPrint('✓ Global error handler initialized');
  }

  // ── Log error to Firebase Crashlytics ─────────────
  static void _logToFirebase(
    Object error,
    StackTrace stack, {
    String? context,
    bool isFatal = false,
  }) {
    try {
      final sanitizedMessage = SensitiveDataGuard.sanitizeErrorMessage(error.toString());
      
      FirebaseCrashlytics.instance.recordError(
        sanitizedMessage,
        stack,
        reason: context,
        fatal: isFatal,
        printDetails: kDebugMode,
      );
    } catch (e) {
      // Don't throw from error handler
      debugPrint('Crashlytics logging failed: $e');
    }
  }

  // ── Manual error logging ───────────────────────────
  // Call this for non-fatal caught errors you want
  // to track in Crashlytics
  static void logError(
    Object error,
    StackTrace? stack, {
    String? reason,
    Map<String, String>? extras,
  }) {
    if (kDebugMode) {
      debugPrint('─── ERROR LOGGED ─────────────────');
      debugPrint('Reason: $reason');
      debugPrint('Error: $error');
      if (stack != null) debugPrint(stack.toString());
      debugPrint('──────────────────────────────────');
      return;
    }

    // In release: send to Crashlytics
    if (extras != null) {
      for (final entry in extras.entries) {
        FirebaseCrashlytics.instance.setCustomKey(entry.key, entry.value);
      }
    }

    final sanitizedMessage = SensitiveDataGuard.sanitizeErrorMessage(error.toString());

    FirebaseCrashlytics.instance.recordError(
      sanitizedMessage,
      stack ?? StackTrace.empty,
      reason: reason,
      printDetails: false,
    );
  }

  // ── Set user context for crash reports ────────────
  // Call after successful login
  static Future<void> setUserContext(
    String userId,
    String email,
  ) async {
    if (kReleaseMode) {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
      await FirebaseCrashlytics.instance.setCustomKey('email_hash', email.hashCode.toString());
      // NEVER log actual email — only hash
    }
  }

  // ── Clear user context ─────────────────────────────
  // Call on logout
  static Future<void> clearUserContext() async {
    if (kReleaseMode) {
      await FirebaseCrashlytics.instance.setUserIdentifier('');
    }
  }
}
