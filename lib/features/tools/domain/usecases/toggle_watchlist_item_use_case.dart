import '../../data/datasources/watchlist_firestore_data_source.dart';

class ToggleWatchlistItemUseCase {
  ToggleWatchlistItemUseCase(this._dataSource);

  final WatchlistFirestoreDataSource _dataSource;

  /// Retorna `true` se o filme ficou na watchlist.
  Future<bool> call({
    required String userId,
    required int tmdbMovieId,
    required String title,
    String? posterPath,
    required bool isCurrentlyInList,
  }) async {
    if (isCurrentlyInList) {
      await _dataSource.removeItem(userId: userId, tmdbMovieId: tmdbMovieId);
      return false;
    }
    await _dataSource.addItem(
      userId: userId,
      tmdbMovieId: tmdbMovieId,
      title: title,
      posterPath: posterPath,
    );
    return true;
  }
}
