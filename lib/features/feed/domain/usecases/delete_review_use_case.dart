import '../../../../core/errors/app_exception.dart';
import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class DeleteReviewUseCase {
  DeleteReviewUseCase(this._repository);

  final ReviewRepository _repository;

  /// Só o autor exclui a própria avaliação.
  Future<void> call({required ReviewEntity review, required String userId}) async {
    if (review.authorId != userId) {
      throw const AppException(
        message: 'Você só pode excluir as suas avaliações.',
        type: AppExceptionType.validation,
      );
    }
    await _repository.deleteReview(review.id);
  }
}
