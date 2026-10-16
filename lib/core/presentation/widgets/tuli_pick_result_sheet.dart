import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_theme.dart';
import 'tuli_button.dart';
import 'tuli_meta_row.dart';
import 'tuli_poster_image.dart';
import 'tuli_score_pill.dart';

/// Resultado de sorteio de filme (Girar a sorte / roleta da watchlist).
class TuliPickResultSheet extends StatelessWidget {
  const TuliPickResultSheet({
    super.key,
    required this.title,
    this.posterPath,
    this.year,
    this.voteAverage,
    this.overview,
    required this.onOpenDetails,
    this.onSpinAgain,
  });

  final String title;
  final String? posterPath;
  final String? year;
  final double? voteAverage;
  final String? overview;
  final VoidCallback onOpenDetails;
  final VoidCallback? onSpinAgain;

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? posterPath,
    String? year,
    double? voteAverage,
    String? overview,
    required VoidCallback onOpenDetails,
    VoidCallback? onSpinAgain,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TuliPickResultSheet(
        title: title,
        posterPath: posterPath,
        year: year,
        voteAverage: voteAverage,
        overview: overview,
        onOpenDetails: onOpenDetails,
        onSpinAgain: onSpinAgain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final synopsis = overview?.trim() ?? '';

    void closeThen(VoidCallback action) {
      Navigator.of(context).pop();
      action();
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppShape.radiusLg)),
        border: Border(top: BorderSide(color: AppColors.borderElevated)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.md,
        AppSpacing.xxl,
        AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderElevated,
              borderRadius: AppShape.borderRadiusPill,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.casino_rounded, size: 18, color: AppColors.gold),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'A SORTE ESCOLHEU',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppShape.borderRadiusMd,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  blurRadius: AppEffects.blur(32),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: TuliPosterImage(
              posterPath: posterPath,
              width: 150,
              borderRadius: AppShape.borderRadiusMd,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TuliMetaRow(year: year),
              if (voteAverage != null && voteAverage! > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                TuliScorePill(score: voteAverage!, compact: true),
              ],
            ],
          ),
          if (synopsis.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              synopsis,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          TuliButton(
            label: 'Ver detalhes',
            icon: Icons.movie_outlined,
            expand: true,
            onPressed: () => closeThen(onOpenDetails),
          ),
          if (onSpinAgain != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TuliButton(
              label: 'Girar de novo',
              icon: Icons.refresh_rounded,
              variant: TuliButtonVariant.ghost,
              expand: true,
              onPressed: () => closeThen(onSpinAgain!),
            ),
          ],
        ],
      ),
    );
  }
}
