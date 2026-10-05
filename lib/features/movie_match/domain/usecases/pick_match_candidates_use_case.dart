import '../../../feed/domain/repositories/review_repository.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../movies/domain/repositories/movie_repository.dart';
import '../entities/match_candidate_entity.dart';
import '../entities/match_filters_entity.dart';

class PickMatchCandidatesUseCase {
  PickMatchCandidatesUseCase({
    required MovieRepository movieRepository,
    required ReviewRepository reviewRepository,
  })  : _movies = movieRepository,
        _reviews = reviewRepository;

  final MovieRepository _movies;
  final ReviewRepository _reviews;

  static const candidateCount = 10;

  Future<List<MatchCandidateEntity>> call({
    required Set<String> participantIds,
    required MatchFiltersEntity filters,
  }) async {
    final watched = await _reviews.watchedMovieIdsForUsers(participantIds);
    final picked = <MatchCandidateEntity>[];
    var page = 1;

    while (picked.length < candidateCount && page <= 5) {
      final batch = await _movies.discoverMovies(
        page: page,
        withWatchProviderId: filters.withWatchProviderId,
        runtimeLteMinutes: filters.maxRuntimeMinutes,
        withGenres: filters.genreId?.toString(),
      );

      for (final movie in batch) {
        if (watched.contains(movie.id)) continue;
        if (picked.any((c) => c.tmdbMovieId == movie.id)) continue;

        picked.add(_toCandidate(movie));
        if (picked.length >= candidateCount) break;
      }
      page++;
    }

    return picked;
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
