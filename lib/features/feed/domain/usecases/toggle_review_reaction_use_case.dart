import '../repositories/review_repository.dart';

class ToggleReviewReactionUseCase {
  ToggleReviewReactionUseCase(this._repository);

  final ReviewRepository _repository;

  Future<void> call({
    required String reviewId,
    required String userId,
    required String reactionKey,
  }) {
    return _repository.toggleReaction(
      reviewId: reviewId,
      userId: userId,
      reactionKey: reactionKey,
    );
  }
}
