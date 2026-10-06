import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';

class DiscoverCarouselWidget extends StatelessWidget {
  static const compactCarouselHeight = 228.0;

  const DiscoverCarouselWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.movies,
    this.streamingLabel,
    this.onMarkWatched,
    this.onAddWatchlist,
    this.groupWatchedMovieIds = const {},
  });

  final String title;
  final String subtitle;
  final List<MovieEntity> movies;
  final String? streamingLabel;
  final void Function(MovieEntity movie)? onMarkWatched;
  final void Function(MovieEntity movie)? onAddWatchlist;
  final Set<int> groupWatchedMovieIds;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: compactCarouselHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = movies[index];
              final year = movie.releaseDate != null && movie.releaseDate!.length >= 4
                  ? movie.releaseDate!.substring(0, 4)
                  : null;

              return MovieCardWidget(
                title: movie.title,
                posterPath: movie.posterPath,
                year: year,
                voteAverage: movie.voteAverage,
                compact: true,
                titleBelowPoster: false,
                showGroupWatchedBadge: groupWatchedMovieIds.contains(movie.id),
                streamingProviderLabel:
                    groupWatchedMovieIds.contains(movie.id) ? null : streamingLabel,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MovieDetailsPage(movieId: movie.id),
                    ),
                  );
                },
                onMarkWatched: onMarkWatched == null ? null : () => onMarkWatched!(movie),
                onAddWatchlist: onAddWatchlist == null ? null : () => onAddWatchlist!(movie),
              );
            },
          ),
        ),
      ],
    );
  }
}
