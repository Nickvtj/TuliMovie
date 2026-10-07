import 'package:flutter/material.dart';

/// Paleta centralizada do TuliMovie — cinematic dark (#0D0E12).
abstract final class AppColors {
  // Backgrounds
  static const Color backgroundDeep = Color(0xFF0D0E12);
  static const Color surface = Color(0xFF13151B);
  static const Color surfaceElevated = Color(0xFF181A20);
  static const Color surfaceMuted = Color(0xFF1C1F26);
  static const Color chipInactive = Color(0xFF1C1F26);

  // Brand
  static const Color gold = Color(0xFFFFB800);
  static const Color goldDim = Color(0xFFFFA000);
  static const Color goldMuted = Color(0x59FFB800);
  static const Color primaryGlow = Color(0x59FFB800);

  // Alert / polêmia
  static const Color neonRed = Color(0xFFFF2E93);
  static const Color neonRedDeep = Color(0xFFFF0055);
  static const Color neonRedMuted = Color(0x33FF2E93);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A5B1);
  static const Color textMuted = Color(0xFF6B7280);

  // Borders & dividers
  static const Color borderSubtle = Color(0xFF1F232D);
  static const Color borderElevated = Color(0xFF2A2D37);
  static const Color divider = Color(0xFF1F232D);

  // Semantic
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = neonRedDeep;

  // Stars (rating)
  static const Color starFilled = gold;
  static const Color starEmpty = Color(0xFF4A4A58);
}
