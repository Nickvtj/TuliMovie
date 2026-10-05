import '../../../feed/domain/entities/review_entity.dart';

abstract interface class ProfileRepository {
  Future<List<ReviewEntity>> fetchReviewsForUser(String userId);
}
