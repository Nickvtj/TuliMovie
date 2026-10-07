import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'tuli_button.dart';

/// Shell visual para modais inferiores (handle, cantos, rodapé padrão).
class TuliBottomSheet extends StatelessWidget {
  const TuliBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.onCancel,
    this.onApply,
    this.applyLabel = 'Aplicar',
    this.cancelLabel = 'Cancelar',
    this.showActions = true,
  });

  final String title;
  final Widget child;
  final VoidCallback? onCancel;
  final VoidCallback? onApply;
  final String applyLabel;
  final String cancelLabel;
  final bool showActions;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    VoidCallback? onApply,
    bool showActions = true,
    String applyLabel = 'Aplicar',
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return TuliBottomSheet(
          title: title,
          showActions: showActions,
          applyLabel: applyLabel,
          onCancel: () => Navigator.pop(ctx),
          onApply: onApply == null ? null : () => onApply(),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.08),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShape.radiusLg)),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderElevated,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: child,
              ),
            ),
            if (showActions && (onCancel != null || onApply != null)) ...[
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, bottom + AppSpacing.lg),
                child: Row(
                  children: [
                    if (onCancel != null)
                      Expanded(
                        child: TuliButton(
                          label: cancelLabel,
                          variant: TuliButtonVariant.secondary,
                          onPressed: onCancel,
                        ),
                      ),
                    if (onCancel != null && onApply != null) const SizedBox(width: AppSpacing.md),
                    if (onApply != null)
                      Expanded(
                        child: TuliButton(
                          label: applyLabel,
                          onPressed: onApply,
                        ),
                      ),
                  ],
                ),
              ),
            ] else
              SizedBox(height: bottom + AppSpacing.lg),
          ],
          ),
        ),
      ),
    );
  }
}

/// Tema dourado para sliders dentro de bottom sheets.
SliderThemeData tuliSliderTheme(BuildContext context) {
  return SliderTheme.of(context).copyWith(
    activeTrackColor: AppColors.gold,
    inactiveTrackColor: AppColors.surfaceElevated,
    thumbColor: AppColors.gold,
    overlayColor: AppColors.gold.withValues(alpha: 0.12),
    rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
  );
}
