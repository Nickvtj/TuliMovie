import '../repositories/review_repository.dart';

class GetFeedPageUseCase {
  GetFeedPageUseCase(this._repository);

  final ReviewRepository _repository;

  Future<FeedPageResult> call({
    String? groupId,
    List<String>? groupIds,
    required int limit,
    FeedCursor? cursor,
  }) {
    if (groupId != null) {
      return _repository.fetchFeedPage(groupId: groupId, limit: limit, cursor: cursor);
    }
    return _repository.fetchMergedFeedPage(
      groupIds: groupIds ?? const [],
      limit: limit,
      cursor: cursor,
    );
  }
}
