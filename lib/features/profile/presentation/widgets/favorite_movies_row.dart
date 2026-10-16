import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/favorite_movie_entity.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';
import 'empty_favorite_slot.dart';

/// Quatro pôsteres lado a lado; vagas vazias convidam a escolher (se editável).
class FavoriteMoviesRow extends StatelessWidget {
  const FavoriteMoviesRow({super.key, required this.movies, this.onAdd});

  static const slots = 4;

  final List<FavoriteMovieEntity> movies;

  /// Quando presente, vagas vazias viram atalho para escolher filmes.
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < slots; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: index < movies.length
                ? _MovieSlot(movie: movies[index], textTheme: textTheme)
                : AspectRatio(
                    aspectRatio: 2 / 3,
                    child: EmptyFavoriteSlot(onTap: onAdd),
                  ),
          ),
        ],
      ],
    );
  }
}

class _MovieSlot extends StatelessWidget {
  const _MovieSlot({required this.movie, required this.textTheme});

  final FavoriteMovieEntity movie;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppShape.borderRadiusSm,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => MovieDetailsPage(movieId: movie.tmdbMovieId)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: TuliPosterImage(posterPath: movie.posterPath, expand: true),
          ),
          const SizedBox(height: 6),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
