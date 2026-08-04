import 'package:flutter/material.dart';

/// Centralized color palette for the GreenMind AI application.
/// All UI colors should be referenced from this class.

class AppColors {
  AppColors._();

  // =========================
  // Primary Colors
  // =========================

  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);

  // =========================
  // Secondary Colors
  // =========================

  static const Color secondary = Color(0xFF66BB6A);

  // =========================
  // Background Colors
  // =========================

  static const Color background = Color(0xFFF7F9F5);
  static const Color surface = Colors.white;

  // =========================
  // Text Colors
  // =========================

  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Colors.white;

  // =========================
  // Status Colors
  // =========================

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  // =========================
  // Border & Divider
  // =========================

  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFEEEEEE);

  // =========================
  // Disabled
  // =========================

  static const Color disabled = Color(0xFFBDBDBD);

  // =========================
  // Card Shadow
  // =========================

  static const Color shadow = Color(0x14000000);
}