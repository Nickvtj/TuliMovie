import '../../../feed/domain/repositories/review_repository.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../movies/domain/repositories/movie_repository.dart';
import '../../../profile/domain/repositories/watched_movies_repository.dart';
import '../../../tools/data/datasources/watchlist_firestore_data_source.dart';
import '../entities/match_candidate_entity.dart';
import '../entities/match_filters_entity.dart';

class PickMatchCandidatesUseCase {
  PickMatchCandidatesUseCase({
    required MovieRepository movieRepository,
    required ReviewRepository reviewRepository,
    required WatchedMoviesRepository watchedMoviesRepository,
    required WatchlistFirestoreDataSource watchlistDataSource,
  })  : _movies = movieRepository,
        _reviews = reviewRepository,
        _watchedMovies = watchedMoviesRepository,
        _watchlist = watchlistDataSource;

  final MovieRepository _movies;
  final ReviewRepository _reviews;
  final WatchedMoviesRepository _watchedMovies;
  final WatchlistFirestoreDataSource _watchlist;

  /// Filmes por lote; ao chegar perto do fim, o Match busca o próximo.
  static const candidateCount = 15;

  /// Teto de páginas do TMDB lidas por lote (quando quase tudo já foi visto).
  static const maxPagesPerBatch = 5;

  /// [hostId] é dono da watchlist usada quando o filtro pede (só no 1º lote).
  /// [excludeIds]: filmes que já estão na rodada.
  Future<MatchCandidatesBatch> call({
    required String hostId,
    required Set<String> participantIds,
    required MatchFiltersEntity filters,
    int startPage = 1,
    Set<int> excludeIds = const {},
  }) async {
    final fromReviews = await _reviews.watchedMovieIdsForUsers(participantIds);
    final personal = <int>{};
    for (final userId in participantIds) {
      personal.addAll(await _safePersonalWatched(userId));
    }
    final skip = {...fromReviews, ...personal, ...excludeIds};

    final picked = <MatchCandidateEntity>[];
    void add(MatchCandidateEntity candidate) {
      if (skip.add(candidate.tmdbMovieId)) picked.add(candidate);
    }

    if (filters.includeWatchlist && startPage == 1) {
      final items = await _watchlist.watchItems(userId: hostId).first;
      for (final item in items) {
        add(
          MatchCandidateEntity(
            tmdbMovieId: item.tmdbMovieId,
            title: item.title,
            posterPath: item.posterPath,
          ),
        );
      }
    }

    // Ordem do TMDB preservada: do mais votado para o menos avaliado.
    var page = startPage;
    var hasMore = true;
    while (picked.length < candidateCount && page < startPage + maxPagesPerBatch) {
      final result = await _movies.discoverMoviesQuery(filters.toDiscoverQuery(page: page));
      page++;
      result.movies.map(_toCandidate).forEach(add);
      if (!result.hasMore) {
        hasMore = false;
        break;
      }
    }

    return MatchCandidatesBatch(candidates: picked, nextPage: hasMore ? page : null);
  }

  Future<Set<int>> _safePersonalWatched(String userId) async {
    try {
      return await _watchedMovies.getWatchedMovieIds(userId);
    } catch (_) {
      return {};
    }
  }

  MatchCandidateEntity _toCandidate(MovieEntity movie) {
    int? year;
    final date = movie.releaseDate;
    if (date != null && date.length >= 4) {
      year = int.tryParse(date.substring(0, 4));
    }

    return MatchCandidateEntity(
      tmdbMovieId: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      overview: movie.overview,
      releaseYear: year,
    );
  }
}

class MatchCandidatesBatch {
  const MatchCandidatesBatch({required this.candidates, required this.nextPage});

  final List<MatchCandidateEntity> candidates;

  /// Página do TMDB para o próximo lote; `null` quando não há mais filmes.
  final int? nextPage;
}
