import '../entities/review_entity.dart';

/// Cursor opaco para paginação — presentation não depende do Firestore.
abstract interface class FeedCursor {
  const FeedCursor();
}

class FeedPageResult {
  const FeedPageResult({
    required this.reviews,
    required this.hasMore,
    this.nextCursor,
  });

  final List<ReviewEntity> reviews;
  final bool hasMore;
  final FeedCursor? nextCursor;
}

abstract interface class ReviewRepository {
  Future<FeedPageResult> fetchFeedPage({
    required int limit,
    FeedCursor? cursor,
  });

  Future<List<ReviewEntity>> getReviewsByMovieId(int tmdbMovieId);

  Future<List<ReviewEntity>> getReviewsByMovieIds(List<int> tmdbMovieIds);

  Future<void> toggleReaction({
    required String reviewId,
    required String userId,
    required String reactionKey,
  });
}
