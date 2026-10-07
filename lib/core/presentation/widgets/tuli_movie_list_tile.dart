import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'tuli_card.dart';
import 'tuli_meta_row.dart';
import 'tuli_poster_image.dart';
import 'tuli_score_pill.dart';

/// Linha padrão filme (poster + metadados) — busca/descubra.
class TuliMovieListTile extends StatelessWidget {
  const TuliMovieListTile({
    super.key,
    required this.title,
    this.posterPath,
    this.year,
    this.genreLabel,
    this.voteAverage,
    this.runtimeLabel,
    this.isUpcoming = false,
    this.onTap,
    this.onWantToWatch,
    this.trailing,
  });

  final String title;
  final String? posterPath;
  final String? year;
  final String? genreLabel;
  final double? voteAverage;
  final String? runtimeLabel;
  final bool isUpcoming;
  final VoidCallback? onTap;
  final VoidCallback? onWantToWatch;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: isUpcoming ? AppColors.gold : AppColors.textPrimary,
    );

    return TuliCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TuliPosterImage(posterPath: posterPath, width: 56),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (genreLabel != null && genreLabel!.isNotEmpty)
                      Text(
                        genreLabel!.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    Text(
                      title,
                      style: titleStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    TuliMetaRow(
                      year: year,
                      extra: runtimeLabel,
                    ),
                    if (isUpcoming) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Anunciado • Em produção',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              if (voteAverage != null && voteAverage! > 0)
                TuliScorePill(score: voteAverage!, compact: true),
              if (trailing != null) trailing!,
            ],
          ),
          if (isUpcoming && onWantToWatch != null) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onWantToWatch,
                child: const Text('Quero Assistir'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
