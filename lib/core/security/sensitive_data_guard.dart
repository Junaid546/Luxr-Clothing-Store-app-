import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Guards sensitive data from being logged, cached,
// or exposed in error messages.

class SensitiveDataGuard {
  SensitiveDataGuard._();

  // ── Mask sensitive strings for logging ────────────
  static String maskEmail(String email) {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length != 2) return '***@***';
    final username = parts[0];
    final domain = parts[1];
    // Show first 2 chars only: jo***@gmail.com
    if (username.length <= 2) {
      return '$username***@$domain';
    }
    return '${username.substring(0, 2)}***@$domain';
  }

  static String maskPhone(String phone) {
    if (phone.length < 7) return '***';
    // Show last 4 digits only: ***-1234
    return '***${phone.substring(phone.length - 4)}';
  }

  static String maskCardNumber(String card) {
    if (card.length < 4) return '****';
    return '**** **** **** ${card.substring(card.length - 4)}';
  }

  // ── Prevent sensitive data in debug prints ─────────
  // Override debugPrint in production to be no-op
  static void setupDebugLogging() {
    if (kReleaseMode) {
      // Override debugPrint to do nothing in release
      debugPrint = (String? message, {int? wrapWidth}) {};
    }
  }

  // ── Prevent screenshot in sensitive screens ────────
  // Add to cart, checkout, and profile screens
  static Future<void> preventScreenshot(
    BuildContext context,
  ) async {
    // iOS: automatic via UITextField secureTextEntry
    // Android: use FLAG_SECURE
    if (Platform.isAndroid) {
      // This requires method channel implementation
      // in native Android code — placeholder for now
    }
  }

  // ── Validate no sensitive data in exceptions ───────
  // Call before logging any exception message
  static String sanitizeErrorMessage(String message) {
    // Remove potential email addresses
    message = message.replaceAll(
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      '[EMAIL]',
    );
    // Remove potential phone numbers
    message = message.replaceAll(
      RegExp(r'\b[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}\b'),
      '[PHONE]',
    );
    // Remove potential credit card numbers
    message = message.replaceAll(
      RegExp(r'\b[0-9]{4}[\s-]?[0-9]{4}[\s-]?[0-9]{4}[\s-]?[0-9]{4}\b'),
      '[CARD]',
    );
    // Remove Firebase project IDs from messages
    message = message.replaceAll(
      RegExp(r'projects/[a-z0-9\-]+/'),
      'projects/[PROJECT]/',
    );
    return message;
  }
}
