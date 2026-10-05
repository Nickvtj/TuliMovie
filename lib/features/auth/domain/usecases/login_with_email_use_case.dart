import '../../../../core/errors/app_exception.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  LoginWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    _validateLogin(normalizedEmail, password);

    try {
      return await _repository.loginWithEmail(
        email: normalizedEmail,
        password: password,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Não foi possível entrar.', cause: e);
    }
  }

  void _validateLogin(String email, String password) {
    if (!_isValidEmail(email)) {
      throw const AppException(
        message: 'E-mail inválido.',
        type: AppExceptionType.validation,
      );
    }
    if (password.length < 6) {
      throw const AppException(
        message: 'Senha deve ter ao menos 6 caracteres.',
        type: AppExceptionType.validation,
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }
}
