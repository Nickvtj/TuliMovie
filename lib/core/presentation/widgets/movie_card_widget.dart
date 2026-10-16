import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'tuli_meta_row.dart';
import 'tuli_poster_image.dart';
import 'tuli_score_pill.dart';

class MovieCardWidget extends StatelessWidget {
  const MovieCardWidget({
    super.key,
    required this.title,
    this.posterPath,
    this.year,
    this.genreLabel,
    this.voteAverage,
    this.streamingProviderLabel,
    this.onTap,
    this.onMarkWatched,
    this.onAddWatchlist,
    this.onRemove,
    this.compact = false,
    this.titleBelowPoster = true,
    this.showGroupWatchedBadge = false,
    this.isWatched = false,
    this.isInWatchlist = false,
  });

  final String title;
  final String? posterPath;
  final String? year;
  final String? genreLabel;
  final double? voteAverage;
  final String? streamingProviderLabel;
  final VoidCallback? onTap;
  final VoidCallback? onMarkWatched;
  final VoidCallback? onAddWatchlist;

  /// Remove o filme de uma lista (ex.: Minha watchlist).
  final VoidCallback? onRemove;
  final bool compact;
  final bool titleBelowPoster;
  final bool showGroupWatchedBadge;
  final bool isWatched;
  final bool isInWatchlist;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: AppShape.borderRadiusMd,
                    child: TuliPosterImage(
                      posterPath: posterPath,
                      expand: true,
                      borderRadius: AppShape.borderRadiusMd,
                    ),
                  ),
                ),
                if (showGroupWatchedBadge)
                  const Positioned(
                    top: 6,
                    left: 6,
                    child: _IconBadge(icon: Icons.visibility, tooltip: 'Visto pela turma'),
                  )
                else if (streamingProviderLabel != null)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: _MiniBadge(label: streamingProviderLabel!),
                  ),
                if (voteAverage != null && voteAverage! > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: TuliScorePill(score: voteAverage!, compact: true),
                  ),
                if (!titleBelowPoster)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.92),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelMedium?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (titleBelowPoster) ...[
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelLarge,
            ),
            if (year != null || (genreLabel != null && genreLabel!.isNotEmpty))
              TuliMetaRow(year: year, genreLabel: genreLabel),
          ],
          if (onAddWatchlist != null || onMarkWatched != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (onAddWatchlist != null)
                  Expanded(
                    child: _CardAction(
                      icon: isInWatchlist ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                      label: isInWatchlist ? 'Salvo' : 'Quero ver',
                      tooltip: isInWatchlist ? 'Remover da watchlist' : 'Salvar para ver depois',
                      active: isInWatchlist,
                      onPressed: onAddWatchlist!,
                    ),
                  ),
                if (onAddWatchlist != null && onMarkWatched != null)
                  const SizedBox(width: 6),
                if (onMarkWatched != null)
                  Expanded(
                    child: _CardAction(
                      icon: isWatched ? Icons.check_circle_rounded : Icons.visibility_outlined,
                      label: isWatched ? 'Visto' : 'Já vi',
                      tooltip: isWatched ? 'Já assistido' : 'Marcar como assistido',
                      active: isWatched,
                      onPressed: onMarkWatched!,
                    ),
                  ),
              ],
            ),
          ],
          if (onRemove != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _CardAction(
              icon: Icons.delete_outline_rounded,
              label: 'Remover',
              tooltip: 'Remover da lista',
              onPressed: onRemove!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Ação rotulada abaixo do card (salvar / já vi) — dourada quando ativa.
class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.gold : AppColors.textSecondary;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? AppColors.gold.withValues(alpha: 0.14) : AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: AppShape.borderRadiusPill,
          side: BorderSide(
            color: active ? AppColors.gold.withValues(alpha: 0.5) : AppColors.borderSubtle,
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: SizedBox(
            height: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.tooltip});

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 14, color: AppColors.gold),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.gold),
        ),
      ),
    );
  }
}

