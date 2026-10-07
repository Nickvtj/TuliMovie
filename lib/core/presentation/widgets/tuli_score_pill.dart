import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class TuliScorePill extends StatelessWidget {
  const TuliScorePill({
    super.key,
    required this.score,
    this.compact = false,
  });

  final double score;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = score.toStringAsFixed(1);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: AppShape.borderRadiusSm,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 3 : 4,
        ),
        child: Text(
          '★ $label',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 11 : 12,
              ),
        ),
      ),
    );
  }
}
