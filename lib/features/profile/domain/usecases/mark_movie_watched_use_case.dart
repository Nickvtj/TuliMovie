import '../entities/watched_movie_entity.dart';
import '../repositories/watched_movies_repository.dart';

class MarkMovieWatchedUseCase {
  MarkMovieWatchedUseCase(this._repository);

  final WatchedMoviesRepository _repository;

  Future<void> call({
    required String userId,
    required int tmdbMovieId,
    required String title,
    String? posterPath,
    WatchedMovieSource source = WatchedMovieSource.discover,
  }) {
    return _repository.markAsWatched(
      userId: userId,
      tmdbMovieId: tmdbMovieId,
      title: title,
      posterPath: posterPath,
      source: source,
    );
  }
}
