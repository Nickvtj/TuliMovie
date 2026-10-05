import '../../../feed/data/datasources/review_firestore_data_source.dart';
import '../../../feed/data/mappers/review_mapper.dart';
import '../../../feed/domain/entities/review_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._reviews);

  final ReviewFirestoreDataSource _reviews;

  @override
  Future<List<ReviewEntity>> fetchReviewsForUser(String userId) async {
    final models = await _reviews.fetchRecentReviews(limit: 400);
    final entities = ReviewMapper.toEntityList(models);

    return entities
        .where((review) => review.participants.any((p) => p.userId == userId))
        .toList();
  }
}
