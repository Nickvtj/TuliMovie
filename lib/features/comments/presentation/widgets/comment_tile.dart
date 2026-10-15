import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/relative_time_pt.dart';
import '../../../social/presentation/pages/user_profile_page.dart';
import '../../domain/entities/comment_entity.dart';
import 'mention_text.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment});

  final CommentEntity comment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    void openAuthor() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => UserProfilePage(userId: comment.authorId)),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: openAuthor,
          child: TuliRingAvatar(
            displayName: comment.authorName,
            imageUrl: comment.authorPhotoUrl,
            size: 34,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: openAuthor,
                child: Text.rich(
                  TextSpan(
                    text: comment.authorName,
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                    children: [
                      TextSpan(
                        text: '  ${formatRelativeTimePt(comment.createdAt)}',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              MentionText(text: comment.text, mentions: comment.mentions),
            ],
          ),
        ),
      ],
    );
  }
}
