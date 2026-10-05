import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/services/image_export_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/tmdb_image_url.dart';
import '../../../feed/domain/entities/review_entity.dart';

/// Canvas 9:16 isolado para exportação (PNG / Stories).
class ReviewShareCardWidget extends StatelessWidget {
  const ReviewShareCardWidget({
    super.key,
    required this.review,
    this.highlightQuote,
  });

  final ReviewEntity review;
  final String? highlightQuote;

  @override
  Widget build(BuildContext context) {
    final quote = (highlightQuote ?? review.comment ?? '').trim();
    final posterUrl = TmdbImageUrl.poster(review.moviePosterPath, size: 'w780');
    final year = review.movieReleaseYear != null ? ' (${review.movieReleaseYear})' : '';

    return SizedBox(
      width: ImageExportService.storyCanvasSize.width,
      height: ImageExportService.storyCanvasSize.height,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundVignette,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'TuliMovie',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  if (review.hasDiscordBadge) const DiscordBadge(compact: true),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: AppShape.borderRadiusLg,
                  child: posterUrl == null
                      ? Container(color: AppColors.surfaceMuted)
                      : CachedNetworkImage(
                          imageUrl: posterUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${review.movieTitle}$year',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TuliRatingStars(
                    value: review.groupAverageRating,
                    readOnly: true,
                    starSize: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${review.groupAverageRating.toStringAsFixed(1)} · Galera',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.gold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              UserAvatarGroup(
                imageUrls: review.participants.map((p) => p.photoUrl).toList(),
                initials: review.participants.map((p) => _initials(p.displayName)).toList(),
                size: 34,
                maxVisible: 6,
              ),
              if (quote.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  '“$quote”',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
              const Spacer(),
              Text(
                'A comunidade de cinema da turma',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
        ),
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
