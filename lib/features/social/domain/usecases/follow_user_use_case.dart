import '../../../../core/errors/app_exception.dart';
import '../repositories/social_repository.dart';

class FollowUserUseCase {
  FollowUserUseCase(this._repository);

  final SocialRepository _repository;

  Future<void> call({required String userId, required String targetId}) async {
    if (userId == targetId) {
      throw const AppException(
        message: 'Você não pode seguir a si mesmo.',
        type: AppExceptionType.validation,
      );
    }

    try {
      await _repository.follow(userId: userId, targetId: targetId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Não foi possível seguir.', cause: e);
    }
  }
}
