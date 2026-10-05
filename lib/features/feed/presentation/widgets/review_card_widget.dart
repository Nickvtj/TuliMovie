import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/constants/quick_reactions.dart';
import '../../domain/entities/review_entity.dart';
import 'quick_reactions_sheet.dart';

typedef ReviewCardTap = void Function(ReviewEntity review);

/// Card modular do feed — compõe apenas widgets do design system.
class ReviewCardWidget extends StatelessWidget {
  const ReviewCardWidget({
    super.key,
    required this.review,
    this.onOpenMovie,
    this.onReact,
    this.compact = false,
  });

  final ReviewEntity review;
  final ReviewCardTap? onOpenMovie;
  final Future<void> Function(String reactionKey)? onReact;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final year = review.movieReleaseYear != null ? ' (${review.movieReleaseYear})' : '';

    return TuliCard(
      onTap: onOpenMovie == null ? null : () => onOpenMovie!(review),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TuliPosterImage(
                posterPath: review.moviePosterPath,
                width: compact ? 64 : 72,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${review.movieTitle}$year',
                            style: textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (review.hasDiscordBadge) ...[
                          const SizedBox(width: 8),
                          const DiscordBadge(compact: true),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    TuliRatingStars(
                      value: review.groupAverageRating,
                      readOnly: true,
                      starSize: compact ? 18 : 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${review.groupAverageRating.toStringAsFixed(1)} · Galera',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.gold),
                    ),
                    const SizedBox(height: 10),
                    UserAvatarGroup(
                      imageUrls: review.participants.map((p) => p.photoUrl).toList(),
                      initials: review.participants.map((p) => _initials(p.displayName)).toList(),
                      size: compact ? 28 : 32,
                      maxVisible: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          _ReactionStrip(review: review),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onReact == null
                  ? null
                  : () async {
                      final key = await showQuickReactionsSheet(context);
                      if (key != null) await onReact!(key);
                    },
              icon: const Icon(Icons.add_reaction_outlined, size: 18),
              label: const Text('Reagir'),
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final token = parts.first;
      return (token.length >= 2 ? token.substring(0, 2) : token).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
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
          borderRadius: AppShape.borderRadiusSm,
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
