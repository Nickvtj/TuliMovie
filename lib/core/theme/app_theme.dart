import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Design tokens de forma e motion usados pelo Theme e pelos widgets core.
abstract final class AppShape {
  static const double radiusMd = 16;
  static const double radiusSm = 12;
  static const double radiusLg = 24;

  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
}

abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.gold,
      onPrimary: Color(0xFF1A1400),
      secondary: AppColors.neonRed,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.borderSubtle,
      surfaceContainerHighest: AppColors.surfaceElevated,
      surfaceContainerHigh: AppColors.surfaceMuted,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDeep,
      canvasColor: AppColors.backgroundDeep,
      dividerColor: AppColors.divider,
      splashColor: AppColors.gold.withValues(alpha: 0.12),
      highlightColor: AppColors.gold.withValues(alpha: 0.08),
      textTheme: AppTypography.textTheme(
        ThemeData.dark().textTheme,
      ),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.backgroundDeep,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.backgroundDeep,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppShape.borderRadiusMd,
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppShape.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppShape.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppShape.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppShape.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.neonRedDeep),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppShape.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.neonRed, width: 1.5),
        ),
        hintStyle: base.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        labelStyle: base.textTheme.bodyMedium,
        errorStyle: base.textTheme.bodySmall?.copyWith(color: AppColors.neonRed),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppShape.borderRadiusMd),
          textStyle: base.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: base.textTheme.labelLarge,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppShape.borderRadiusSm),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        circularTrackColor: AppColors.surfaceMuted,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
