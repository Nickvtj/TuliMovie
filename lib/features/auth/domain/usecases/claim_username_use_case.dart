import '../../../../core/errors/app_exception.dart';
import '../repositories/auth_repository.dart';
import '../utils/username_rules.dart';

class ClaimUsernameUseCase {
  ClaimUsernameUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String userId,
    required String username,
  }) async {
    final normalized = UsernameRules.normalize(username);
    final error = UsernameRules.validate(normalized);
    if (error != null) {
      throw AppException(message: error, type: AppExceptionType.validation);
    }

    try {
      await _repository.claimUsername(userId: userId, username: normalized);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Não foi possível salvar seu @.', cause: e);
    }
  }
}
