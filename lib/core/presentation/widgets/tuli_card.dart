import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_theme.dart';

enum TuliCardVariant { standard, elevated, goldAccent, alert }

/// Card base do design system — bordas 16px, opcional glow dourado ou alerta neon.
class TuliCard extends StatefulWidget {
  const TuliCard({
    super.key,
    required this.child,
    this.variant = TuliCardVariant.standard,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.margin,
    this.width,
    this.height,
  });

  final Widget child;
  final TuliCardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  @override
  State<TuliCard> createState() => _TuliCardState();
}

class _TuliCardState extends State<TuliCard> {
  bool _pressed = false;

  Color get _backgroundColor {
    switch (widget.variant) {
      case TuliCardVariant.standard:
        return AppColors.surface;
      case TuliCardVariant.elevated:
        return AppColors.surfaceElevated;
      case TuliCardVariant.goldAccent:
        return AppColors.surface;
      case TuliCardVariant.alert:
        return AppColors.surface;
    }
  }

  Border? get _border {
    switch (widget.variant) {
      case TuliCardVariant.standard:
        return Border.all(color: AppColors.borderSubtle);
      case TuliCardVariant.elevated:
        return Border.all(color: AppColors.borderSubtle.withValues(alpha: 0.6));
      case TuliCardVariant.goldAccent:
        return Border.all(color: AppColors.gold.withValues(alpha: 0.45));
      case TuliCardVariant.alert:
        return Border.all(color: AppColors.neonRed.withValues(alpha: 0.55));
    }
  }

  List<BoxShadow>? get _shadow {
    if (widget.variant == TuliCardVariant.elevated) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
    }
    if (widget.variant == TuliCardVariant.goldAccent) {
      return [
        BoxShadow(
          color: AppColors.gold.withValues(alpha: 0.12),
          blurRadius: 20,
          spreadRadius: -4,
        ),
      ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: AppShape.borderRadiusMd,
        border: _border,
        boxShadow: _shadow,
        gradient: widget.variant == TuliCardVariant.goldAccent
            ? AppGradients.goldSubtle
            : null,
      ),
      child: Padding(
        padding: widget.padding,
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (value) => setState(() => _pressed = value),
        borderRadius: AppShape.borderRadiusMd,
        splashColor: AppColors.gold.withValues(alpha: 0.1),
        highlightColor: AppColors.gold.withValues(alpha: 0.05),
        child: content,
      ),
    );
  }
}
