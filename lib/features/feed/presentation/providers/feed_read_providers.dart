import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/feed_last_seen_storage.dart';
import 'feed_providers.dart';

final feedLastSeenStorageProvider = Provider((_) => FeedLastSeenStorage());

final feedLastSeenProvider =
    StateNotifierProvider<FeedLastSeenNotifier, AsyncValue<DateTime?>>((ref) {
  return FeedLastSeenNotifier(ref.watch(feedLastSeenStorageProvider));
});

class FeedLastSeenNotifier extends StateNotifier<AsyncValue<DateTime?>> {
  FeedLastSeenNotifier(this._storage) : super(const AsyncValue.loading()) {
    _load();
  }

  final FeedLastSeenStorage _storage;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _storage.read());
  }

  Future<void> markSeenUpTo(DateTime timestamp) async {
    final current = state.valueOrNull;
    if (current != null && !timestamp.isAfter(current)) return;
    await _storage.write(timestamp);
    state = AsyncValue.data(timestamp);
  }
}

/// `true` quando existe review mais recente que o último visto no Feed.
final feedHasNewReviewsProvider = Provider<bool>((ref) {
  final lastSeenAsync = ref.watch(feedLastSeenProvider);
  final feed = ref.watch(feedNotifierProvider);

  if (feed.reviews.isEmpty) return false;
  if (lastSeenAsync.isLoading) return false;

  final lastSeen = lastSeenAsync.valueOrNull;
  if (lastSeen == null) return true;

  return feed.reviews.any((review) => review.createdAt.isAfter(lastSeen));
});

/// Marca o feed como lido até a review mais recente carregada.
void markFeedAsSeen(WidgetRef ref) {
  final feed = ref.read(feedNotifierProvider);
  final notifier = ref.read(feedLastSeenProvider.notifier);

  if (feed.reviews.isEmpty) {
    notifier.markSeenUpTo(DateTime.now());
    return;
  }

  var latest = feed.reviews.first.createdAt;
  for (final review in feed.reviews) {
    if (review.createdAt.isAfter(latest)) latest = review.createdAt;
  }
  notifier.markSeenUpTo(latest);
}
