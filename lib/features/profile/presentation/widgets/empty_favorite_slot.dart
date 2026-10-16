import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Vaga de favorito ainda não escolhida — "+" quando editável.
class EmptyFavoriteSlot extends StatelessWidget {
  const EmptyFavoriteSlot({super.key, this.onTap, this.circular = false});

  final VoidCallback? onTap;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final shape = circular
        ? const CircleBorder(side: BorderSide(color: AppColors.borderElevated))
        : RoundedRectangleBorder(
            borderRadius: AppShape.borderRadiusSm,
            side: const BorderSide(color: AppColors.borderElevated),
          );

    return Material(
      color: AppColors.surfaceElevated.withValues(alpha: 0.5),
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Center(
          child: Icon(
            onTap == null ? Icons.remove_rounded : Icons.add_rounded,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
