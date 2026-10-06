import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';

class DiscoverMovieSection extends StatelessWidget {
  const DiscoverMovieSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.movies,
  });

  final String title;
  final String subtitle;
  final List<MovieEntity> movies;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleLarge),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
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

              return _DiscoverPosterCard(
                movie: movie,
                year: year,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MovieDetailsPage(movieId: movie.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DiscoverPosterCard extends StatelessWidget {
  const _DiscoverPosterCard({
    required this.movie,
    required this.year,
    required this.onTap,
  });

  final MovieEntity movie;
  final String? year;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppShape.borderRadiusMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TuliPosterImage(
                  posterPath: movie.posterPath,
                  expand: true,
                  borderRadius: AppShape.borderRadiusMd,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (year != null)
                Text(year!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
