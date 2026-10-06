import '../../data/datasources/watchlist_firestore_data_source.dart';

class ToggleWatchlistItemUseCase {
  ToggleWatchlistItemUseCase(this._dataSource);

  final WatchlistFirestoreDataSource _dataSource;

  Future<bool> call({
    required int tmdbMovieId,
    required String title,
    String? posterPath,
    required bool isCurrentlyInList,
  }) async {
    if (isCurrentlyInList) {
      await _dataSource.removeItem(tmdbMovieId: tmdbMovieId);
      return false;
    }
    await _dataSource.addItem(
      tmdbMovieId: tmdbMovieId,
      title: title,
      posterPath: posterPath,
    );
    return true;
  }
}
