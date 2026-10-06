import '../entities/watched_movie_entity.dart';

abstract interface class WatchedMoviesRepository {
  Future<Set<int>> getWatchedMovieIds(String userId);

  Future<void> markAsWatched({
    required String userId,
    required int tmdbMovieId,
    required String title,
    String? posterPath,
    WatchedMovieSource source = WatchedMovieSource.discover,
  });

  Future<List<WatchedMovieEntity>> listWatched(String userId, {int limit = 200});
}
