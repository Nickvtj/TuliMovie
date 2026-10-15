import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/relative_time_pt.dart';
import '../../../comments/presentation/pages/review_comments_page.dart';
import '../../../movie_match/presentation/pages/match_room_page.dart';
import '../../../social/presentation/pages/user_profile_page.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification});

  final NotificationEntity notification;

  String get _message {
    final movie = notification.movieTitle == null ? '' : ' de ${notification.movieTitle}';
    return switch (notification.type) {
      NotificationType.follow => 'começou a seguir você.',
      NotificationType.comment => 'comentou na sua avaliação$movie.',
      NotificationType.mention => 'mencionou você em um comentário$movie.',
      NotificationType.matchInvite => 'chamou você para um Match de filmes 🎬',
    };
  }

  void _open(BuildContext context) {
    final reviewId = notification.reviewId;
    final roomId = notification.roomId;
    final Widget page = switch (notification.type) {
      NotificationType.matchInvite when roomId != null => MatchRoomPage(roomId: roomId),
      NotificationType.comment || NotificationType.mention when reviewId != null =>
        ReviewCommentsPage(reviewId: reviewId),
      _ => UserProfilePage(userId: notification.actorId),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final snippet = notification.text;

    return TuliCard(
      variant: notification.read ? TuliCardVariant.standard : TuliCardVariant.goldAccent,
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => _open(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TuliRingAvatar(
            displayName: notification.actorName,
            imageUrl: notification.actorPhotoUrl,
            size: 40,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: notification.actorName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' $_message'),
                    ],
                  ),
                  style: textTheme.bodyMedium,
                ),
                if (snippet != null && snippet.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '“$snippet”',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  formatRelativeTimePt(notification.createdAt),
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
