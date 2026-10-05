import 'package:flutter/material.dart';

/// Paleta centralizada do TuliMovie — nunca use hex solto nas features.
abstract final class AppColors {
  // Backgrounds
  static const Color backgroundDeep = Color(0xFF0F0F14);
  static const Color surface = Color(0xFF1A1A22);
  static const Color surfaceElevated = Color(0xFF24242E);
  static const Color surfaceMuted = Color(0xFF2E2E3A);

  // Brand
  static const Color gold = Color(0xFFFFC107);
  static const Color goldDim = Color(0xFFE6AC00);
  static const Color goldMuted = Color(0x33FFC107);

  // Alert / polêmia
  static const Color neonRed = Color(0xFFFF2E93);
  static const Color neonRedDeep = Color(0xFFFF0055);
  static const Color neonRedMuted = Color(0x33FF2E93);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFB0B0BC);
  static const Color textMuted = Color(0xFF6E6E7A);

  // Borders & dividers
  static const Color borderSubtle = Color(0xFF3A3A48);
  static const Color divider = Color(0xFF2A2A34);

  // Semantic
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = neonRedDeep;

  // Stars (rating)
  static const Color starFilled = gold;
  static const Color starEmpty = Color(0xFF4A4A58);
}
