import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class GetReviewByIdUseCase {
  GetReviewByIdUseCase(this._repository);

  final ReviewRepository _repository;

  Future<ReviewEntity?> call(String reviewId) => _repository.getReviewById(reviewId);
}
