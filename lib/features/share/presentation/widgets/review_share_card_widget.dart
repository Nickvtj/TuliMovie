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
    final textTheme = Theme.of(context).textTheme;
    final quote = (highlightQuote ?? review.comment ?? '').trim();
    final posterUrl = TmdbImageUrl.poster(review.moviePosterPath, size: 'w780');
    final author = review.participants.isNotEmpty ? review.participants.first : null;
    final rating = author?.rating ?? review.groupAverageRating;

    return SizedBox(
      width: ImageExportService.storyCanvasSize.width,
      height: ImageExportService.storyCanvasSize.height,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundVignette),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'TuliMovie',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (review.hasDiscordBadge) const DiscordBadge(compact: true),
                ],
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              Text(
                review.movieTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              if (review.movieReleaseYear != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${review.movieReleaseYear}',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  TuliRatingStars(value: rating, readOnly: true, starSize: 22),
                  const SizedBox(width: 10),
                  Text(
                    rating.toStringAsFixed(1),
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              if (quote.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '“$quote”',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
              if (author != null) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    TuliRingAvatar(
                      displayName: author.displayName,
                      imageUrl: author.photoUrl,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Avaliado por ${author.displayName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              Text(
                'tulimovie · cinema entre amigos',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
