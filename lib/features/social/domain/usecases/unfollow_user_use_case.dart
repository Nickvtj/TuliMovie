import '../../../../core/errors/app_exception.dart';
import '../repositories/social_repository.dart';

class UnfollowUserUseCase {
  UnfollowUserUseCase(this._repository);

  final SocialRepository _repository;

  Future<void> call({required String userId, required String targetId}) async {
    try {
      await _repository.unfollow(userId: userId, targetId: targetId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Não foi possível deixar de seguir.', cause: e);
    }
  }
}
