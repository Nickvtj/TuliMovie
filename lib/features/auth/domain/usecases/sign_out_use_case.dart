import '../../../../core/errors/app_exception.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() async {
    try {
      await _repository.signOut();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Erro ao sair da conta.', cause: e);
    }
  }
}
