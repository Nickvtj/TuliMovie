import '../../../feed/data/datasources/review_firestore_data_source.dart';
import '../../../feed/data/mappers/review_mapper.dart';
import '../../../feed/domain/entities/review_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._reviews);

  /// Teto de avaliações lidas para montar o perfil.
  static const reviewsLimit = 400;

  final ReviewFirestoreDataSource _reviews;

  /// Avaliações publicadas pelo próprio usuário.
  @override
  Future<List<ReviewEntity>> fetchReviewsForUser(String userId) async {
    final models = await _reviews.fetchByAuthor(userId, limit: reviewsLimit);
    return ReviewMapper.toEntityList(models);
  }
}
