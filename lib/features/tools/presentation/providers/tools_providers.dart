import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../data/datasources/cinepass_firestore_data_source.dart';
import '../../data/datasources/watchlist_firestore_data_source.dart';
import '../../domain/entities/cinepass_entity.dart';
import '../../domain/entities/watchlist_item_entity.dart';

final watchlistFirestoreProvider = Provider(
  (ref) => sl<WatchlistFirestoreDataSource>(),
);

final cinepassFirestoreProvider = Provider(
  (ref) => sl<CinepassFirestoreDataSource>(),
);

final watchlistItemsProvider = StreamProvider<List<WatchlistItemEntity>>((ref) {
  return ref.watch(watchlistFirestoreProvider).watchItems();
});

final watchlistMovieIdsProvider = Provider<Set<int>>((ref) {
  return ref.watch(watchlistItemsProvider).maybeWhen(
        data: (items) => items.map((item) => item.tmdbMovieId).toSet(),
        orElse: () => <int>{},
      );
});

final cinepassStateProvider = StreamProvider<CinepassStateEntity>((ref) {
  return ref.watch(cinepassFirestoreProvider).watchState();
});
