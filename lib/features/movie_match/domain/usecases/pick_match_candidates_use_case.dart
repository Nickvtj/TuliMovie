import 'dart:math';

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

  static const candidateCount = 15;

  Future<List<MatchCandidateEntity>> call({
    required String groupId,
    required Set<String> participantIds,
    required MatchFiltersEntity filters,
  }) async {
    final fromReviews = await _reviews.watchedMovieIdsForUsers(participantIds);
    final personal = <int>{};
    for (final userId in participantIds) {
      personal.addAll(await _safePersonalWatched(userId));
    }
    final watched = {...fromReviews, ...personal};

    final picked = <MatchCandidateEntity>[];
    final random = Random();

    if (filters.includeGroupWatchlist) {
      final items = await _watchlist.watchItems(groupId: groupId).first;
      for (final item in items) {
        if (watched.contains(item.tmdbMovieId)) continue;
        picked.add(
          MatchCandidateEntity(
            tmdbMovieId: item.tmdbMovieId,
            title: item.title,
            posterPath: item.posterPath,
          ),
        );
        if (picked.length >= candidateCount) break;
      }
    }

    var page = 1;
    while (picked.length < candidateCount && page <= 5) {
      final classicQuery = filters.toDiscoverQuery(page: page).copyWith(
            primaryReleaseDateGte: filters.releaseYearFrom == null
                ? '1980-01-01'
                : '${filters.releaseYearFrom}-01-01',
            primaryReleaseDateLte: filters.releaseYearTo == null
                ? '2010-12-31'
                : '${filters.releaseYearTo}-12-31',
            voteAverageGte: 7.0,
            sortBy: 'vote_average.desc',
          );

      final recentQuery = filters.toDiscoverQuery(page: page).copyWith(
            primaryReleaseDateGte: '${DateTime.now().year - 3}-01-01',
            sortBy: 'release_date.desc',
          );

      final batches = await Future.wait([
        _movies.discoverMoviesQuery(classicQuery),
        _movies.discoverMoviesQuery(recentQuery),
      ]);

      final pool = [...batches[0].movies, ...batches[1].movies];
      pool.shuffle(random);

      for (final movie in pool) {
        if (watched.contains(movie.id)) continue;
        if (picked.any((c) => c.tmdbMovieId == movie.id)) continue;
        picked.add(_toCandidate(movie));
        if (picked.length >= candidateCount) break;
      }
      page++;
    }

    picked.shuffle(random);
    return picked.take(candidateCount).toList();
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
