import '../../../../core/errors/app_exception.dart';
import '../../data/local/auth_remember_me_storage.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  SignOutUseCase(this._repository, this._rememberMeStorage);

  final AuthRepository _repository;
  final AuthRememberMeStorage _rememberMeStorage;

  Future<void> call() async {
    try {
      await _repository.signOut();
      await _rememberMeStorage.clearSession();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Erro ao sair da conta.', cause: e);
    }
  }
}
