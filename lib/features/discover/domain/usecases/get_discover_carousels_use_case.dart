import '../../../feed/domain/repositories/review_repository.dart';
import '../../../movies/domain/entities/discover_query_entity.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../movies/domain/repositories/movie_repository.dart';
import '../entities/discover_filter_entity.dart';
import '../entities/discover_home_entity.dart';

class GetDiscoverCarouselsUseCase {
  GetDiscoverCarouselsUseCase({
    required MovieRepository movies,
    required ReviewRepository reviews,
  })  : _movies = movies,
        _reviews = reviews;

  final MovieRepository _movies;
  final ReviewRepository _reviews;

  Future<List<DiscoverSectionEntity>> call(
    DiscoverFilterEntity filters, {
    required String groupId,
  }) async {
    if (!filters.usesMixedFeed) {
      final page = await _movies.discoverMoviesQuery(filters.toDiscoverQuery(page: 1));
      if (page.movies.isEmpty) return const [];

      return [
        DiscoverSectionEntity(
          id: 'filtered',
          title: filters.primaryGenreLabel,
          subtitle: 'Sugestões com o filtro selecionado',
          movies: page.movies.take(16).toList(),
        ),
      ];
    }

    final groupSection = await _groupWatchingSection(groupId);

    final queries = <({String id, String title, String subtitle, DiscoverQueryEntity query})>[
      (
        id: 'pearls_80_90',
        title: 'Pérolas Esquecidas dos Anos 80 e 90',
        subtitle: 'Clássicos fora do hype atual',
        query: const DiscoverQueryEntity(
          primaryReleaseDateGte: '1980-01-01',
          primaryReleaseDateLte: '1999-12-31',
          voteAverageGte: 6.5,
          sortBy: 'vote_average.desc',
        ),
      ),
      (
        id: 'short_direct',
        title: 'Curtos e Diretos no Ponto',
        subtitle: 'Menos de 90 minutos',
        query: const DiscoverQueryEntity(
          runtimeLteMinutes: 90,
          sortBy: 'popularity.desc',
        ),
      ),
      (
        id: 'heroes_beyond',
        title: 'Heróis Além do Clichê',
        subtitle: 'Ação e fantasia com boa nota',
        query: const DiscoverQueryEntity(
          withGenres: [28, 14],
          voteAverageGte: 7.0,
          sortBy: 'vote_average.desc',
        ),
      ),
      (
        id: 'hidden_gems',
        title: 'Surpresas Escondidas',
        subtitle: 'Nota alta, poucos votos',
        query: const DiscoverQueryEntity(
          voteAverageGte: 7.5,
          voteCountLte: 800,
          sortBy: 'vote_average.desc',
        ),
      ),
    ];

    final sections = <DiscoverSectionEntity>[];
    if (groupSection != null) sections.add(groupSection);

    for (final item in queries) {
      final page = await _movies.discoverMoviesQuery(item.query.copyWith(page: 1));
      if (page.movies.isEmpty) continue;
      sections.add(
        DiscoverSectionEntity(
          id: item.id,
          title: item.title,
          subtitle: item.subtitle,
          movies: page.movies.take(12).toList(),
        ),
      );
    }

    return sections;
  }

  Future<DiscoverSectionEntity?> _groupWatchingSection(String groupId) async {
    final feed = await _reviews.fetchFeedPage(groupId: groupId, limit: 30);
    final movieIds = feed.reviews.map((r) => r.tmdbMovieId).toSet().take(10).toList();
    if (movieIds.isEmpty) return null;

    final movies = <MovieEntity>[];
    for (final id in movieIds) {
      try {
        final details = await _movies.getMovieDetails(movieId: id);
        movies.add(details.movie);
      } catch (_) {
        continue;
      }
    }

    if (movies.isEmpty) return null;

    return DiscoverSectionEntity(
      id: 'group_watching',
      title: 'O Que a Turma Andou Vendo',
      subtitle: 'Baseado nas avaliações recentes',
      movies: movies,
    );
  }
}
