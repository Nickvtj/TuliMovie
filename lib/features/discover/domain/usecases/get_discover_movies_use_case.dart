import '../../../movies/domain/entities/discover_query_entity.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../movies/domain/repositories/movie_repository.dart';
import '../../../profile/domain/repositories/watched_movies_repository.dart';
import '../entities/discover_filter_entity.dart';
import '../services/discover_mixed_feed_generator.dart';

class GetDiscoverMoviesUseCase {
  GetDiscoverMoviesUseCase({
    required MovieRepository movies,
    required WatchedMoviesRepository watchedMovies,
  })  : _movies = movies,
        _watchedMovies = watchedMovies;

  final MovieRepository _movies;
  final WatchedMoviesRepository _watchedMovies;

  Future<DiscoverMoviesPage> call({
    required String userId,
    required DiscoverFilterEntity filters,
    required int page,
  }) async {
    final excludeIds = await _safeWatchedIds(userId);

    if (!filters.usesMixedFeed) {
      final query = filters.toDiscoverQuery(page: page);
      final result = await _movies.discoverMoviesQuery(query);
      final filtered = _filterExcluded(result.movies, excludeIds);
      return DiscoverMoviesPage(
        movies: filtered,
        page: result.page,
        hasMore: result.hasMore,
      );
    }

    final queries = DiscoverMixedFeedGenerator.queriesForPage(page);
    final base = filters.toDiscoverQuery(page: page);

    final results = await Future.wait(
      queries.map((segment) {
        final merged = _mergeSegmentWithBase(segment: segment, base: base);
        return _movies.discoverMoviesQuery(merged);
      }),
    );

    final merged = DiscoverMixedFeedGenerator.mergePageResults(
      recent: results[0].movies,
      classics: results[1].movies,
      hidden: results[2].movies,
      excludeIds: excludeIds,
    );

    return DiscoverMoviesPage(
      movies: merged,
      page: page,
      hasMore: results.any((r) => r.hasMore),
    );
  }

  DiscoverQueryEntity _mergeSegmentWithBase({
    required DiscoverQueryEntity segment,
    required DiscoverQueryEntity base,
  }) {
    return DiscoverQueryEntity(
      page: segment.page,
      withWatchProviderIds: base.withWatchProviderIds,
      withGenres: base.withGenres.isNotEmpty ? base.withGenres : segment.withGenres,
      primaryReleaseDateGte: segment.primaryReleaseDateGte ?? base.primaryReleaseDateGte,
      primaryReleaseDateLte: segment.primaryReleaseDateLte ?? base.primaryReleaseDateLte,
      runtimeLteMinutes: base.runtimeLteMinutes ?? segment.runtimeLteMinutes,
      voteAverageGte: _maxVote(base.voteAverageGte, segment.voteAverageGte),
      voteCountLte: segment.voteCountLte ?? base.voteCountLte,
      sortBy: segment.sortBy,
    );
  }

  static double? _maxVote(double? a, double? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a > b ? a : b;
  }

  Future<Set<int>> _safeWatchedIds(String userId) async {
    try {
      return await _watchedMovies.getWatchedMovieIds(userId);
    } catch (_) {
      return {};
    }
  }

  List<MovieEntity> _filterExcluded(List<MovieEntity> movies, Set<int> excludeIds) {
    return movies.where((m) => !excludeIds.contains(m.id)).toList();
  }
}

class DiscoverMoviesPage {
  const DiscoverMoviesPage({
    required this.movies,
    required this.page,
    required this.hasMore,
  });

  final List<MovieEntity> movies;
  final int page;
  final bool hasMore;
}
