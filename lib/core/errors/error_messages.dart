import 'package:flutter/foundation.dart';

// Maps internal error codes to user-safe messages.
// NEVER expose stack traces, internal paths, or
// database structure to the user.
// Generic errors in production, detailed in debug.

class ErrorMessages {
  ErrorMessages._();

  // ── Firebase Auth error mapping ────────────────────
  static String fromFirebaseAuthCode(String code) => switch (code) {
        'user-not-found' => 'No account found with this email address.',
        'wrong-password' => 'Incorrect password. Please try again.',
        'invalid-credential' => 'Invalid login credentials. Please try again.',
        'email-already-in-use' =>
          'An account with this email already exists. Try signing in instead.',
        'weak-password' =>
          'Password is too weak. Please choose a stronger password.',
        'user-disabled' =>
          'This account has been suspended. Please contact support.',
        'too-many-requests' =>
          'Too many failed attempts. Please wait a few minutes before trying again.',
        'network-request-failed' =>
          'Connection failed. Please check your internet connection and try again.',
        'invalid-email' => 'Please enter a valid email address.',
        'operation-not-allowed' =>
          'This login method is not enabled. Please contact support.',
        'account-exists-with-different-credential' =>
          'An account already exists with this email using a different sign-in method.',
        'requires-recent-login' =>
          'For security, please sign in again to complete this action.',
        'credential-already-in-use' =>
          'This credential is already linked to another account.',
        _ => kDebugMode
            ? 'Auth error: $code'
            : 'Authentication failed. Please try again.',
      };

  // ── Firestore error mapping ────────────────────────
  static String fromFirestoreCode(String? code) => switch (code) {
        'permission-denied' =>
          'You don\'t have permission to perform this action.',
        'not-found' => 'The requested resource was not found.',
        'already-exists' => 'This record already exists.',
        'resource-exhausted' => 'Too many requests. Please try again later.',
        'unavailable' => 'Service temporarily unavailable. Please try again.',
        'deadline-exceeded' =>
          'The operation timed out. Please check your connection.',
        'cancelled' => 'The operation was cancelled.',
        _ => kDebugMode
            ? 'Firestore error: $code'
            : 'A server error occurred. Please try again.',
      };

  // ── Generic user-safe messages ─────────────────────
  static const String networkError =
      'Connection failed. Please check your internet connection.';

  static const String serverError =
      'Something went wrong on our end. Please try again in a moment.';

  static const String sessionExpired =
      'Your session has expired. Please sign in again.';

  static const String permissionDenied =
      'You don\'t have permission to do this.';

  static const String itemNotFound = 'This item no longer exists.';

  static const String outOfStock =
      'Sorry, this item is no longer available in the selected size.';

  static const String cartFull =
      'Your cart is full. Please remove an item before adding more.';

  static const String orderPlacementFailed =
      'Unable to place your order. Please check your cart and try again.';

  static const String imageTooLarge =
      'Image size must be under 5MB. Please choose a smaller image.';

  static const String invalidFileType =
      'Only JPG, PNG and WEBP images are supported.';
}
