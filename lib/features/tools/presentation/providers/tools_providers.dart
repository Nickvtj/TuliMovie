import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../groups/presentation/providers/group_providers.dart';
import '../../data/datasources/watchlist_firestore_data_source.dart';
import '../../domain/entities/watchlist_item_entity.dart';

final watchlistFirestoreProvider = Provider(
  (ref) => sl<WatchlistFirestoreDataSource>(),
);

final watchlistItemsForGroupProvider =
    StreamProvider.family<List<WatchlistItemEntity>, String>((ref, groupId) {
  return ref.watch(watchlistFirestoreProvider).watchItems(groupId: groupId);
});

final watchlistViewGroupIdProvider = StateProvider<String?>((ref) => null);

final watchlistItemsProvider = Provider<AsyncValue<List<WatchlistItemEntity>>>((ref) {
  final groupId = ref.watch(watchlistViewGroupIdProvider);
  if (groupId == null) return const AsyncValue.data([]);
  return ref.watch(watchlistItemsForGroupProvider(groupId));
});

final watchlistMovieIdsProvider = Provider<Set<int>>((ref) {
  final groups = ref.watch(userGroupsProvider).valueOrNull ?? [];
  final ids = <int>{};
  for (final group in groups) {
    final items = ref.watch(watchlistItemsForGroupProvider(group.id)).valueOrNull ?? [];
    ids.addAll(items.map((item) => item.tmdbMovieId));
  }
  return ids;
});

final watchlistGroupsForMovieProvider = Provider.family<Set<String>, int>((ref, movieId) {
  final groups = ref.watch(userGroupsProvider).valueOrNull ?? [];
  final result = <String>{};
  for (final group in groups) {
    final items = ref.watch(watchlistItemsForGroupProvider(group.id)).valueOrNull ?? [];
    if (items.any((item) => item.tmdbMovieId == movieId)) {
      result.add(group.id);
    }
  }
  return result;
});
