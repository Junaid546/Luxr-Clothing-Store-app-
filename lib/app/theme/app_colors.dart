import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds
  static const Color backgroundDark = Color(0xFF131318);
  static const Color backgroundLight = Color(0xFFF8F5F5);
  static const Color backgroundCard = Color(0xFF1A0A0A);
  static const Color backgroundElevated = Color(0xFF1F1010);
  static const Color inputBg = Color(0xFF1E1E2A);
  static const Color cardDark = Color(0xFF1C1C24);

  // Primary — Salmon/Coral CTA
  static const Color primary = Color(0xFFFF6B6B);
  static const Color primaryLight = Color(0xFFFF8A8A);
  static const Color primaryDark = Color(0xFFE54B4B);

  // Gold accent (admin dashboard, premium badges)
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8C84A);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF5A5A5A);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color successTeal = Color(0xFF26C6A6);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFE53935);
  static const Color inStock = Color(0xFF26C6A6);
  static const Color lowStock = Color(0xFFE8614A);
  static const Color outOfStock = Color(0xFF5A5A5A);

  // Border
  static const Color borderDefault = Color(0xFF2A1515);
  static const Color borderActive = Color(0xFFE8614A);
  static const Color borderGold = Color(0xFFD4AF37);
}
