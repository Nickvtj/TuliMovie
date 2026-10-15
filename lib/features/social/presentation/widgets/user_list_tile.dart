import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../pages/user_profile_page.dart';

/// Linha de pessoa (busca, seguidores, seguindo) — abre o perfil ao tocar.
class UserListTile extends StatelessWidget {
  const UserListTile({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TuliCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => UserProfilePage(userId: user.id)),
        );
      },
      child: Row(
        children: [
          TuliRingAvatar(displayName: user.displayName, imageUrl: user.photoUrl),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall,
                ),
                if (user.hasUsername)
                  Text(
                    '@${user.username}',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
