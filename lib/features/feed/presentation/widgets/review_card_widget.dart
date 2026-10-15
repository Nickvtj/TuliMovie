import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/relative_time_pt.dart';
import '../../../social/presentation/pages/user_profile_page.dart';
import '../../domain/constants/quick_reactions.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_participant_entity.dart';
import 'quick_reactions_sheet.dart';
import 'spoiler_blur_text.dart';

typedef ReviewCardTap = void Function(ReviewEntity review);

/// Card modular do feed — cabeçalho do autor, bloco do filme e citação.
class ReviewCardWidget extends StatelessWidget {
  const ReviewCardWidget({
    super.key,
    required this.review,
    this.onOpenMovie,
    this.onReact,
    this.onShare,
    this.compact = false,
  });

  final ReviewEntity review;
  final ReviewCardTap? onOpenMovie;
  final Future<void> Function(String reactionKey)? onReact;
  final VoidCallback? onShare;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final author = review.participants.isNotEmpty ? review.participants.first : null;
    final authorRating = author?.rating ?? review.groupAverageRating;
    final timeLabel = formatRelativeTimePt(review.createdAt);
    final watchedWith = review.participants.skip(1).toList();

    return TuliCard(
      onTap: onOpenMovie == null ? null : () => onOpenMovie!(review),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (author != null)
            _AuthorHeader(
              author: author,
              authorId: review.authorId,
              timeLabel: timeLabel,
            ),
          if (watchedWith.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'com ${watchedWith.map((p) => p.displayName).join(', ')}',
              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _MovieBlock(
            review: review,
            authorRating: authorRating,
            compact: compact,
            textTheme: textTheme,
          ),
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            if (review.containsSpoiler)
              SpoilerBlurText(text: review.comment!, maxLines: compact ? 3 : 5)
            else
              TuliQuoteBlock(text: review.comment!, maxLines: compact ? 3 : 5),
          ],
          const SizedBox(height: AppSpacing.md),
          _ReactionStrip(review: review),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onShare != null)
                TextButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.style_outlined, size: 18),
                  label: const Text('Card'),
                ),
              TextButton.icon(
                onPressed: onReact == null
                    ? null
                    : () async {
                        final key = await showQuickReactionsSheet(context);
                        if (key != null) await onReact!(key);
                      },
                icon: const Icon(Icons.add_reaction_outlined, size: 18),
                label: const Text('+ Reagir'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthorHeader extends StatelessWidget {
  const _AuthorHeader({
    required this.author,
    required this.authorId,
    required this.timeLabel,
  });

  final ReviewParticipantEntity author;

  /// Vazio em posts antigos (sem autor gravado) — sem link para o perfil.
  final String authorId;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: AppShape.borderRadiusMd,
      onTap: authorId.isEmpty
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => UserProfilePage(userId: authorId)),
              );
            },
      child: Row(
        children: [
          TuliRingAvatar(
            displayName: author.displayName,
            imageUrl: author.photoUrl,
            size: 40,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author.displayName,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'avaliou $timeLabel',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

class _MovieBlock extends StatelessWidget {
  const _MovieBlock({
    required this.review,
    required this.authorRating,
    required this.compact,
    required this.textTheme,
  });

  final ReviewEntity review;
  final double authorRating;
  final bool compact;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final year = review.movieReleaseYear?.toString();
    final ratedCount = review.participants.where((p) => p.hasSubmittedRating).length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TuliPosterImage(
          posterPath: review.moviePosterPath,
          width: compact ? 64 : 76,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (review.hasDiscordBadge) const DiscordBadge(compact: true),
              Text(
                review.movieTitle,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (year != null) ...[
                const SizedBox(height: 4),
                TuliMetaRow(year: year),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  TuliRatingStars(
                    value: authorRating,
                    readOnly: true,
                    starSize: compact ? 16 : 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    authorRating.toStringAsFixed(1),
                    style: textTheme.labelLarge?.copyWith(color: AppColors.gold),
                  ),
                ],
              ),
              if (ratedCount > 1) ...[
                const SizedBox(height: 4),
                Text(
                  'Média de quem assistiu: ${review.groupAverageRating.toStringAsFixed(1)} ★',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ReactionStrip extends StatelessWidget {
  const _ReactionStrip({required this.review});

  final ReviewEntity review;

  @override
  Widget build(BuildContext context) {
    final chips = QuickReactions.options
        .where((option) => review.reactionCount(option.key) > 0)
        .map((option) {
      final count = review.reactionCount(option.key);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppShape.borderRadiusPill,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Text(
          '${option.emoji} $count',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      );
    }).toList();

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}
