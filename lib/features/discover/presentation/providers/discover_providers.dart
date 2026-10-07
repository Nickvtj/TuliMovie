import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../groups/presentation/providers/group_providers.dart';
import '../../../feed/domain/repositories/review_repository.dart';
import '../../../movies/domain/repositories/movie_repository.dart';
import '../../../profile/domain/repositories/watched_movies_repository.dart';
import '../../../profile/domain/usecases/mark_movie_watched_use_case.dart';
import '../../../tools/domain/usecases/toggle_watchlist_item_use_case.dart';
import '../../domain/entities/discover_filter_entity.dart';
import '../../domain/entities/discover_home_entity.dart';
import '../../domain/usecases/get_discover_carousels_use_case.dart';
import '../../domain/usecases/get_discover_movies_use_case.dart';

final getDiscoverMoviesUseCaseProvider = Provider<GetDiscoverMoviesUseCase>(
  (ref) => GetDiscoverMoviesUseCase(
    movies: sl<MovieRepository>(),
    watchedMovies: sl<WatchedMoviesRepository>(),
  ),
);

final getDiscoverCarouselsUseCaseProvider = Provider<GetDiscoverCarouselsUseCase>(
  (ref) => GetDiscoverCarouselsUseCase(
    movies: sl<MovieRepository>(),
    reviews: sl<ReviewRepository>(),
  ),
);

final markMovieWatchedUseCaseProvider = Provider<MarkMovieWatchedUseCase>(
  (ref) => sl<MarkMovieWatchedUseCase>(),
);

final toggleWatchlistItemUseCaseProvider = Provider<ToggleWatchlistItemUseCase>(
  (ref) => sl<ToggleWatchlistItemUseCase>(),
);

final discoverFiltersProvider =
    StateProvider<DiscoverFilterEntity>((ref) => const DiscoverFilterEntity());

final discoverCarouselsProvider = FutureProvider.autoDispose<List<DiscoverSectionEntity>>((ref) {
  final filters = ref.watch(discoverFiltersProvider);
  final groupId = ref.watch(activeGroupIdProvider);
  if (groupId == null) return Future.value(const []);
  return ref.watch(getDiscoverCarouselsUseCaseProvider).call(filters, groupId: groupId);
});

String? streamingLabelForFilters(DiscoverFilterEntity filters) {
  if (filters.withWatchProviderIds.isEmpty) return null;
  if (filters.withWatchProviderIds.length == 1) {
    final id = filters.withWatchProviderIds.first;
    return switch (id) {
      8 => 'Netflix',
      9 => 'Prime',
      337 => 'Disney+',
      384 => 'Max',
      _ => 'Stream',
    };
  }
  return 'Stream';
}
