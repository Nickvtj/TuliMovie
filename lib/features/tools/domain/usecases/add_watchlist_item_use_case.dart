import '../../data/datasources/watchlist_firestore_data_source.dart';

class AddWatchlistItemUseCase {
  AddWatchlistItemUseCase(this._dataSource);

  final WatchlistFirestoreDataSource _dataSource;

  Future<void> call({
    required int tmdbMovieId,
    required String title,
    String? posterPath,
  }) {
    return _dataSource.addItem(
      tmdbMovieId: tmdbMovieId,
      title: title,
      posterPath: posterPath,
    );
  }
}
