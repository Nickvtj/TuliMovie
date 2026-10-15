import '../../../feed/domain/repositories/review_repository.dart';
import '../entities/tuli_awards_entity.dart';
import '../services/tuli_awards_calculator.dart';

class GetTuliAwardsUseCase {
  GetTuliAwardsUseCase(this._reviews);

  /// Teto de avaliações lidas para montar a retrospectiva.
  static const reviewsLimit = 250;

  final ReviewRepository _reviews;

  Future<TuliAwardsEntity> call({required int year, required String userId}) async {
    final reviews = await _reviews.getReviewsByAuthor(userId, limit: reviewsLimit);
    return TuliAwardsCalculator.build(year: year, userId: userId, reviews: reviews);
  }
}
