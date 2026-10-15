import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/social_providers.dart';
import '../widgets/follow_button.dart';
import '../widgets/follow_stats_row.dart';
import '../widgets/mutual_badge.dart';

/// Perfil público de qualquer usuário.
class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider(userId));
    final status = ref.watch(followStatusProvider(userId));
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: profile.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: TuliFeedSkeleton(itemCount: 2),
          ),
          error: (e, _) => const TuliEmptyState(
            message: 'Não foi possível carregar o perfil.',
            icon: Icons.error_outline_rounded,
          ),
          data: (user) {
            if (user == null) {
              return const TuliEmptyState(
                message: 'Perfil não encontrado.',
                icon: Icons.person_off_outlined,
              );
            }

            return ListView(
              children: [
                TuliScreenHeader(
                  mode: TuliScreenHeaderMode.stacked,
                  title: user.hasUsername ? '@${user.username}' : user.displayName,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      TuliRingAvatar(
                        displayName: user.displayName,
                        imageUrl: user.photoUrl,
                        size: 80,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(user.displayName, style: textTheme.headlineSmall),
                      if (user.hasUsername)
                        Text(
                          '@${user.username}',
                          style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                        ),
                      if (status != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        MutualBadge(status: status),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      FollowStatsRow(userId: userId),
                      const SizedBox(height: AppSpacing.lg),
                      FollowButton(targetId: userId),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
