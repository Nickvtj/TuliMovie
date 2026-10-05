import '../repositories/review_repository.dart';

class GetFeedPageUseCase {
  GetFeedPageUseCase(this._repository);

  final ReviewRepository _repository;

  Future<FeedPageResult> call({
    required int limit,
    FeedCursor? cursor,
  }) {
    return _repository.fetchFeedPage(limit: limit, cursor: cursor);
  }
}
