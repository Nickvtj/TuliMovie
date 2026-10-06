import 'dart:math';

import '../../../movies/domain/entities/discover_query_entity.dart';
import '../../../movies/domain/entities/movie_entity.dart';

/// Combina 30% lançamentos, 40% clássicos (80–2010, nota > 7.5), 30% cult/ocultos.
abstract final class DiscoverMixedFeedGenerator {
  static const _recentShare = 0.30;
  static const _classicShare = 0.40;
  static const _hiddenShare = 0.30;

  static List<DiscoverQueryEntity> queriesForPage(int page) {
    final recentFrom = '${DateTime.now().year - 2}-01-01';
    return [
      DiscoverQueryEntity(
        page: page,
        primaryReleaseDateGte: recentFrom,
        sortBy: 'release_date.desc',
      ),
      DiscoverQueryEntity(
        page: page,
        primaryReleaseDateGte: '1980-01-01',
        primaryReleaseDateLte: '2010-12-31',
        voteAverageGte: 7.5,
        sortBy: 'vote_average.desc',
      ),
      DiscoverQueryEntity(
        page: page,
        voteAverageGte: 7.0,
        voteCountLte: 500,
        sortBy: 'vote_average.desc',
      ),
    ];
  }

  static List<MovieEntity> mergePageResults({
    required List<MovieEntity> recent,
    required List<MovieEntity> classics,
    required List<MovieEntity> hidden,
    required Set<int> excludeIds,
    int targetSize = 20,
  }) {
    final recentTake = max(1, (targetSize * _recentShare).round());
    final classicTake = max(1, (targetSize * _classicShare).round());
    final hiddenTake = max(1, targetSize - recentTake - classicTake);

    final picked = <MovieEntity>[];
    void addFrom(List<MovieEntity> source, int count) {
      for (final movie in source) {
        if (picked.length >= targetSize) return;
        if (excludeIds.contains(movie.id)) continue;
        if (picked.any((m) => m.id == movie.id)) continue;
        picked.add(movie);
        if (--count <= 0) return;
      }
    }

    addFrom(recent, recentTake);
    addFrom(classics, classicTake);
    addFrom(hidden, hiddenTake);

    final pool = [...recent, ...classics, ...hidden];
    pool.shuffle(Random(picked.length + pool.length));
    for (final movie in pool) {
      if (picked.length >= targetSize) break;
      if (excludeIds.contains(movie.id)) continue;
      if (picked.any((m) => m.id == movie.id)) continue;
      picked.add(movie);
    }

    return picked;
  }
}
