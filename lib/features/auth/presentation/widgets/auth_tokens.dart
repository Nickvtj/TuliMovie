import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Tokens do fluxo de auth — cores alinhadas a [AppColors].
abstract final class AuthTokens {
  static const Color background = AppColors.backgroundDeep;
  static const Color toggleTrack = Color(0xFF14161C);
  static const Color surfaceCard = AppColors.surface;
  static const Color cardBorder = AppColors.borderSubtle;
  static const Color inputFill = AppColors.surfaceElevated;
  static const Color inputBorder = AppColors.borderElevated;
  static const Color primaryYellow = AppColors.gold;
  static const Color primaryYellowDark = AppColors.goldDim;
  static const Color primaryGlow = AppColors.primaryGlow;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMuted = AppColors.textMuted;
  static const Color outlineButtonBorder = Color(0xFF3D4451);

  static const Color primaryButtonDisabledFill = Color(0xFF2A2D37);
  static const Color primaryButtonDisabledForeground = Color(0xFF5C6270);

  static const double horizontalPadding = 24;
  static const double maxContentWidth = 480;

  static const double logoBoxSize = 64;
  static const double logoBoxRadius = 16;

  static const double welcomeButtonRadius = 28;
  static const double welcomeButtonVerticalPadding = 16;
  static const Color welcomeGlassFill = Color(0x14FFFFFF);
  static const Color welcomeGlassBorder = Color(0x26FFFFFF);

  static const double buttonRadius = 10;
  static const double toggleTrackRadius = 14;
  static const double toggleTabRadius = 12;
  static const double cardRadius = 16;

  static const double pillButtonVertical = 15;
  static const double inputRadius = 10;

  static const TextStyle welcomeBrand = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.4,
  );

  static const TextStyle welcomeHeadlineLine = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: textPrimary,
    letterSpacing: -0.15,
  );

  static const TextStyle welcomeHeadlineAccent = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: primaryYellow,
    letterSpacing: -0.15,
  );

  static const double welcomeActionsMaxWidth = 360;

  static const TextStyle welcomeSubhead = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Color(0xFFE8EAED),
  );

  static const TextStyle welcomeFooter = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: Color(0xFF7A7F8C),
  );

  static const TextStyle credentialsTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle credentialsSubtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: textSecondary,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: textSecondary,
  );

  static const TextStyle rememberMe = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: textSecondary,
  );

  static const TextStyle footerLink = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle footerLinkAccent = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: primaryYellow,
  );

  static List<BoxShadow> primaryButtonGlow = [
    BoxShadow(
      color: primaryYellow.withValues(alpha: 0.45),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> logoGlowStrong = [
    BoxShadow(
      color: primaryYellow.withValues(alpha: 0.35),
      blurRadius: 30,
      spreadRadius: 5,
    ),
  ];

  static List<BoxShadow> welcomePrimaryGlow = [
    BoxShadow(
      color: primaryYellow.withValues(alpha: 0.5),
      blurRadius: 28,
      spreadRadius: 4,
      offset: Offset(0, 4),
    ),
  ];

  static const Color welcomeSecondaryFill = Color(0xFF12141A);
  static const Color welcomeSecondaryBorder = Color(0x33FFFFFF);
}
