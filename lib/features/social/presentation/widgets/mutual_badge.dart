import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/follow_status_entity.dart';

/// "Amigos" quando os dois se seguem; "Segue você" quando só a pessoa segue.
class MutualBadge extends StatelessWidget {
  const MutualBadge({super.key, required this.status});

  final FollowStatusEntity status;

  @override
  Widget build(BuildContext context) {
    if (!status.followsYou) return const SizedBox.shrink();

    final isMutual = status.isMutual;
    final color = isMutual ? AppColors.gold : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isMutual ? AppColors.goldMuted : AppColors.surfaceElevated,
        borderRadius: AppShape.borderRadiusPill,
        border: Border.all(color: isMutual ? AppColors.gold : AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMutual ? Icons.people_alt_rounded : Icons.person_add_alt_1_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isMutual ? 'Amigos' : 'Segue você',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
