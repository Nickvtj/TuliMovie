import '../../data/datasources/watchlist_firestore_data_source.dart';

class ToggleWatchlistItemUseCase {
  ToggleWatchlistItemUseCase(this._dataSource);

  final WatchlistFirestoreDataSource _dataSource;

  Future<bool> call({
    required String groupId,
    required int tmdbMovieId,
    required String title,
    String? posterPath,
    required bool isCurrentlyInList,
  }) async {
    if (isCurrentlyInList) {
      await _dataSource.removeItem(groupId: groupId, tmdbMovieId: tmdbMovieId);
      return false;
    }
    await _dataSource.addItem(
      groupId: groupId,
      tmdbMovieId: tmdbMovieId,
      title: title,
      posterPath: posterPath,
    );
    return true;
  }
}
