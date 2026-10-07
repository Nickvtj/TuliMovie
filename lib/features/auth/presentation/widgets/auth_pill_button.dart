import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'auth_tokens.dart';

enum AuthPillButtonVariant { primary, outline, welcomeSecondary }

class AuthPillButton extends StatefulWidget {
  const AuthPillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AuthPillButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.showArrow = false,
    this.borderRadius,
    this.solidPrimary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AuthPillButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool showArrow;
  final double? borderRadius;
  final bool solidPrimary;

  @override
  State<AuthPillButton> createState() => _AuthPillButtonState();
}

class _AuthPillButtonState extends State<AuthPillButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  double get _radius => widget.borderRadius ?? AuthTokens.buttonRadius;

  static const _primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFFC933),
      AuthTokens.primaryYellow,
      AuthTokens.primaryYellowDark,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.variant == AuthPillButtonVariant.primary;
    final isWelcomeSecondary = widget.variant == AuthPillButtonVariant.welcomeSecondary;
    final primaryActive = isPrimary && _enabled;
    final fg = isPrimary
        ? (_enabled ? AuthTokens.background : AuthTokens.primaryButtonDisabledForeground)
        : AuthTokens.textPrimary;

    return AnimatedScale(
      scale: _pressed && _enabled ? 0.98 : 1,
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (_enabled) widget.onPressed?.call();
            },
            onHighlightChanged: (v) {
              if (_enabled) setState(() => _pressed = v);
            },
            borderRadius: BorderRadius.circular(_radius),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_radius),
                gradient: primaryActive && !widget.solidPrimary ? _primaryGradient : null,
                color: isPrimary
                    ? (primaryActive
                        ? (widget.solidPrimary ? AuthTokens.primaryYellow : null)
                        : AuthTokens.primaryButtonDisabledFill)
                    : isWelcomeSecondary
                        ? AuthTokens.welcomeSecondaryFill
                        : AuthTokens.welcomeGlassFill,
                border: isPrimary
                    ? null
                    : Border.all(
                        color: isWelcomeSecondary
                            ? AuthTokens.welcomeSecondaryBorder
                            : AuthTokens.outlineButtonBorder.withValues(alpha: 0.85),
                        width: 1,
                      ),
                boxShadow: primaryActive
                    ? (widget.solidPrimary
                        ? AuthTokens.welcomePrimaryGlow
                        : AuthTokens.primaryButtonGlow)
                    : null,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: _radius >= 26
                    ? AuthTokens.welcomeButtonVerticalPadding
                    : AuthTokens.pillButtonVertical,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                    )
                  else ...[
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: fg,
                        letterSpacing: 0.15,
                      ),
                    ),
                    if (widget.icon != null) ...[
                      const SizedBox(width: 10),
                      Icon(widget.icon, size: 20, color: fg),
                    ],
                    if (widget.showArrow) ...[
                      const SizedBox(width: 6),
                      Text(
                        '→',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          height: 1,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
