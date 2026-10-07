import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class TuliFilterChip extends StatelessWidget {
  const TuliFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.backgroundDeep : AppColors.textSecondary,
        );

    return Material(
      color: selected ? AppColors.gold : AppColors.chipInactive,
      borderRadius: AppShape.borderRadiusPill,
      child: InkWell(
        onTap: onSelected,
        borderRadius: AppShape.borderRadiusPill,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded, size: 16, color: AppColors.backgroundDeep),
                const SizedBox(width: 4),
              ],
              Text(label, style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}
