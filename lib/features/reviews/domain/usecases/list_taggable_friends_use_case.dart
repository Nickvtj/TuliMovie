import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../social/domain/repositories/social_repository.dart';

/// Pessoas que o autor pode marcar como "assistiu com": quem ele segue.
class ListTaggableFriendsUseCase {
  ListTaggableFriendsUseCase(this._repository);

  final SocialRepository _repository;

  Future<List<UserEntity>> call(String userId) async {
    try {
      return await _repository.fetchFollowing(userId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Não foi possível carregar quem você segue.', cause: e);
    }
  }
}
