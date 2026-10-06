import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/watched_movie_entity.dart';
import '../../domain/repositories/watched_movies_repository.dart';
import '../datasources/watched_movies_firestore_data_source.dart';

class WatchedMoviesRepositoryImpl implements WatchedMoviesRepository {
  WatchedMoviesRepositoryImpl(this._dataSource);

  final WatchedMoviesFirestoreDataSource _dataSource;

  @override
  Future<Set<int>> getWatchedMovieIds(String userId) async {
    try {
      return await _dataSource.fetchWatchedIds(userId);
    } catch (e) {
      throw AppException(message: 'Erro ao carregar histórico assistido.', cause: e);
    }
  }

  @override
  Future<void> markAsWatched({
    required String userId,
    required int tmdbMovieId,
    required String title,
    String? posterPath,
    WatchedMovieSource source = WatchedMovieSource.discover,
  }) async {
    try {
      await _dataSource.upsertWatched(
        userId: userId,
        tmdbMovieId: tmdbMovieId,
        title: title,
        posterPath: posterPath,
        source: source,
      );
    } catch (e) {
      throw AppException(message: 'Erro ao marcar como assistido.', cause: e);
    }
  }

  @override
  Future<List<WatchedMovieEntity>> listWatched(String userId, {int limit = 200}) async {
    try {
      return await _dataSource.fetchWatched(userId, limit: limit);
    } catch (e) {
      throw AppException(message: 'Erro ao listar assistidos.', cause: e);
    }
  }
}
