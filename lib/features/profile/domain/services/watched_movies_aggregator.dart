import '../../../feed/domain/entities/review_entity.dart';

/// Une assistidos pessoais (Firestore) com filmes em reviews do grupo.
abstract final class WatchedMoviesAggregator {
  static Set<int> movieIdsFromReviews({
    required Set<String> userIds,
    required List<ReviewEntity> reviews,
  }) {
    final watched = <int>{};
    for (final review in reviews) {
      final involved = review.participants.any((p) => userIds.contains(p.userId));
      if (involved) watched.add(review.tmdbMovieId);
    }
    return watched;
  }

  static Set<int> mergeIds(Set<int> personal, Set<int> fromReviews) {
    return {...personal, ...fromReviews};
  }
}
