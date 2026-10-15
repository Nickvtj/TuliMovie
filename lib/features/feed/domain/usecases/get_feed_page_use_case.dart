import '../repositories/review_repository.dart';

class GetFeedPageUseCase {
  GetFeedPageUseCase(this._repository);

  final ReviewRepository _repository;

  /// Feed social do [userId]: posts próprios e de quem ele segue.
  Future<FeedPageResult> call({
    required String userId,
    required int limit,
    FeedCursor? cursor,
  }) {
    return _repository.fetchAudienceFeedPage(userId: userId, limit: limit, cursor: cursor);
  }
}
