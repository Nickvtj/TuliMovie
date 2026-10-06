import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'tuli_poster_image.dart';

class MovieCardWidget extends StatelessWidget {
  const MovieCardWidget({
    super.key,
    required this.title,
    this.posterPath,
    this.year,
    this.voteAverage,
    this.streamingProviderLabel,
    this.onTap,
    this.onMarkWatched,
    this.onAddWatchlist,
    this.compact = false,
    this.titleBelowPoster = true,
    this.showGroupWatchedBadge = false,
    this.isWatched = false,
    this.isInWatchlist = false,
  });

  final String title;
  final String? posterPath;
  final String? year;
  final double? voteAverage;
  final String? streamingProviderLabel;
  final VoidCallback? onTap;
  final VoidCallback? onMarkWatched;
  final VoidCallback? onAddWatchlist;
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
                    child: _MiniBadge(label: voteAverage!.toStringAsFixed(1)),
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
                if (onMarkWatched != null || onAddWatchlist != null)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onMarkWatched != null)
                          _QuickAction(
                            icon: isWatched ? Icons.visibility : Icons.visibility_outlined,
                            tooltip: isWatched ? 'Já assistido' : 'Já vi',
                            onPressed: onMarkWatched!,
                            highlighted: isWatched,
                          ),
                        if (onAddWatchlist != null)
                          _QuickAction(
                            icon: isInWatchlist ? Icons.bookmark : Icons.bookmark_add_outlined,
                            tooltip: isInWatchlist ? 'Remover da watchlist' : 'Quero ver',
                            onPressed: onAddWatchlist!,
                            highlighted: isInWatchlist,
                          ),
                      ],
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
            if (year != null) Text(year!, style: textTheme.bodySmall),
          ],
        ],
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.highlighted = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: highlighted
            ? AppColors.gold.withValues(alpha: 0.35)
            : Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Tooltip(
            message: tooltip,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                icon,
                size: 18,
                color: highlighted ? AppColors.gold : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
