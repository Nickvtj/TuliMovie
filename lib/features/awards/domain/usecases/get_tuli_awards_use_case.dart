import '../../../feed/domain/repositories/review_repository.dart';
import '../entities/tuli_awards_entity.dart';
import '../services/tuli_awards_calculator.dart';

class GetTuliAwardsUseCase {
  GetTuliAwardsUseCase(this._reviews);

  final ReviewRepository _reviews;

  Future<TuliAwardsEntity> call({required int year, required String groupId}) async {
    final page = await _reviews.fetchFeedPage(groupId: groupId, limit: 250);
    return TuliAwardsCalculator.build(year: year, reviews: page.reviews);
  }
}
