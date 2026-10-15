import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../pages/follow_list_page.dart';
import '../providers/social_providers.dart';

/// Contadores "Seguidores · Seguindo" — tocar abre a lista correspondente.
class FollowStatsRow extends ConsumerWidget {
  const FollowStatsRow({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followers = ref.watch(followersCountProvider(userId)).valueOrNull;
    final following = ref.watch(followingCountProvider(userId)).valueOrNull;

    void openList(FollowListTab tab) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FollowListPage(userId: userId, initialTab: tab),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _FollowStat(
          label: 'Seguidores',
          value: followers,
          onTap: () => openList(FollowListTab.followers),
        ),
        const SizedBox(width: AppSpacing.xl),
        _FollowStat(
          label: 'Seguindo',
          value: following,
          onTap: () => openList(FollowListTab.following),
        ),
      ],
    );
  }
}

class _FollowStat extends StatelessWidget {
  const _FollowStat({required this.label, required this.value, required this.onTap});

  final String label;
  final int? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppShape.borderRadiusMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
        child: Column(
          children: [
            Text(
              value?.toString() ?? '–',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(label, style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
