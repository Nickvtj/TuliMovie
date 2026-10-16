import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'tuli_card.dart';
import 'tuli_meta_row.dart';
import 'tuli_poster_image.dart';
import 'tuli_score_pill.dart';

/// Linha padrão de filme (poster + metadados + sinopse) — resultados de busca.
class TuliMovieListTile extends StatelessWidget {
  const TuliMovieListTile({
    super.key,
    required this.title,
    this.posterPath,
    this.year,
    this.genreLabel,
    this.voteAverage,
    this.overview,
    this.isUpcoming = false,
    this.onTap,
  });

  static const _posterWidth = 76.0;
  static const _synopsisMaxLines = 3;

  final String title;
  final String? posterPath;
  final String? year;
  final String? genreLabel;
  final double? voteAverage;
  final String? overview;
  final bool isUpcoming;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final synopsis = overview?.trim() ?? '';
    final hasScore = voteAverage != null && voteAverage! > 0;

    return TuliCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _posterWidth,
            height: _posterWidth * 1.5,
            child: TuliPosterImage(posterPath: posterPath, expand: true),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (hasScore) ...[
                      const SizedBox(width: AppSpacing.sm),
                      TuliScorePill(score: voteAverage!, compact: true),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TuliMetaRow(year: year, genreLabel: genreLabel),
                    if (isUpcoming) const _UpcomingTag(),
                  ],
                ),
                if (synopsis.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    synopsis,
                    maxLines: _synopsisMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingTag extends StatelessWidget {
  const _UpcomingTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: AppShape.borderRadiusPill,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Text(
        'Em breve',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
