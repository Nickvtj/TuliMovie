import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/watchlist_firestore_data_source.dart';
import '../../domain/entities/watchlist_item_entity.dart';

final watchlistFirestoreProvider = Provider(
  (ref) => sl<WatchlistFirestoreDataSource>(),
);

/// Watchlist pessoal do usuário logado.
final watchlistItemsProvider = StreamProvider<List<WatchlistItemEntity>>((ref) {
  final userId = ref.watch(authSessionProvider.select((s) => s.valueOrNull?.id));
  if (userId == null) return Stream.value(const []);
  return ref.watch(watchlistFirestoreProvider).watchItems(userId: userId);
});

final watchlistMovieIdsProvider = Provider<Set<int>>((ref) {
  final items = ref.watch(watchlistItemsProvider).valueOrNull ?? const [];
  return items.map((item) => item.tmdbMovieId).toSet();
});
