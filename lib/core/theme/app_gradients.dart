import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradientes reutilizáveis — cards hero, CTAs, Tuli Awards, etc.
abstract final class AppGradients {
  static const LinearGradient goldShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD54F),
      AppColors.gold,
      Color(0xFFFFB300),
    ],
  );

  static const LinearGradient goldSubtle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x1AFFC107),
      Color(0x00FFC107),
    ],
  );

  static const LinearGradient neonAlert = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.neonRed,
      AppColors.neonRedDeep,
    ],
  );

  static const LinearGradient backgroundVignette = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF16161E),
      AppColors.backgroundDeep,
      Color(0xFF0A0A0E),
    ],
  );

  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0xCC0F0F14),
    ],
  );

  static LinearGradient radialGoldGlow({Alignment center = Alignment.center}) {
    return RadialGradient(
      center: center,
      radius: 0.85,
      colors: [
        AppColors.gold.withValues(alpha: 0.18),
        AppColors.gold.withValues(alpha: 0.0),
      ],
    );
  }
}
