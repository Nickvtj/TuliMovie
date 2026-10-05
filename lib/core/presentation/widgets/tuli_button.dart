import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_theme.dart';

enum TuliButtonVariant { primary, secondary, ghost, destructive }

enum TuliButtonSize { sm, md, lg }

/// Botão unificado com microinteração de escala e estados loading/disabled.
class TuliButton extends StatefulWidget {
  const TuliButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TuliButtonVariant.primary,
    this.size = TuliButtonSize.md,
    this.isLoading = false,
    this.expand = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final TuliButtonVariant variant;
  final TuliButtonSize size;
  final bool isLoading;
  final bool expand;
  final IconData? icon;

  @override
  State<TuliButton> createState() => _TuliButtonState();
}

class _TuliButtonState extends State<TuliButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  EdgeInsets get _padding {
    switch (widget.size) {
      case TuliButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
      case TuliButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
      case TuliButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case TuliButtonSize.sm:
        return 13;
      case TuliButtonSize.md:
        return 15;
      case TuliButtonSize.lg:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = AnimatedScale(
      scale: _pressed && _enabled ? 0.97 : 1,
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _enabled ? 1 : 0.45,
        duration: AppDurations.fast,
        child: _buildSurface(context),
      ),
    );

    if (widget.expand) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }

  Widget _buildSurface(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: _fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: _foregroundColor,
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foregroundColor,
            ),
          ),
          const SizedBox(width: 10),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: _foregroundColor),
          const SizedBox(width: 8),
        ],
        Text(widget.label, style: labelStyle),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _enabled ? widget.onPressed : null,
        onHighlightChanged: (v) => setState(() => _pressed = v),
        borderRadius: AppShape.borderRadiusMd,
        splashColor: _splashColor,
        highlightColor: _highlightColor,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppShape.borderRadiusMd,
            gradient: _gradient,
            color: _backgroundColor,
            border: _border,
            boxShadow: widget.variant == TuliButtonVariant.primary && _enabled
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          padding: _padding,
          child: content,
        ),
      ),
    );
  }

  Color get _foregroundColor {
    switch (widget.variant) {
      case TuliButtonVariant.primary:
        return const Color(0xFF1A1400);
      case TuliButtonVariant.secondary:
        return AppColors.gold;
      case TuliButtonVariant.ghost:
        return AppColors.textPrimary;
      case TuliButtonVariant.destructive:
        return Colors.white;
    }
  }

  Gradient? get _gradient {
    if (!_enabled && widget.variant == TuliButtonVariant.primary) return null;
    switch (widget.variant) {
      case TuliButtonVariant.primary:
        return AppGradients.goldShimmer;
      case TuliButtonVariant.destructive:
        return AppGradients.neonAlert;
      case TuliButtonVariant.secondary:
      case TuliButtonVariant.ghost:
        return null;
    }
  }

  Color? get _backgroundColor {
    switch (widget.variant) {
      case TuliButtonVariant.secondary:
        return AppColors.goldMuted;
      case TuliButtonVariant.ghost:
        return AppColors.surfaceElevated;
      case TuliButtonVariant.primary:
      case TuliButtonVariant.destructive:
        return null;
    }
  }

  Border? get _border {
    switch (widget.variant) {
      case TuliButtonVariant.secondary:
        return Border.all(color: AppColors.gold.withValues(alpha: 0.5));
      case TuliButtonVariant.ghost:
        return Border.all(color: AppColors.borderSubtle);
      default:
        return null;
    }
  }

  Color get _splashColor {
    switch (widget.variant) {
      case TuliButtonVariant.destructive:
        return Colors.white.withValues(alpha: 0.15);
      default:
        return AppColors.gold.withValues(alpha: 0.2);
    }
  }

  Color get _highlightColor {
    switch (widget.variant) {
      case TuliButtonVariant.destructive:
        return Colors.white.withValues(alpha: 0.08);
      default:
        return AppColors.gold.withValues(alpha: 0.1);
    }
  }
}
