import '../../../../core/errors/app_exception.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../utils/username_rules.dart';

class RegisterUseCase {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String password,
    required String confirmPassword,
    required String displayName,
    required String username,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final name = displayName.trim();
    final normalizedUsername = UsernameRules.normalize(username);

    _validateRegister(
      email: normalizedEmail,
      password: password,
      confirmPassword: confirmPassword,
      displayName: name,
      username: normalizedUsername,
    );

    try {
      return await _repository.registerWithEmail(
        email: normalizedEmail,
        password: password,
        displayName: name,
        username: normalizedUsername,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Não foi possível criar a conta.', cause: e);
    }
  }

  void _validateRegister({
    required String email,
    required String password,
    required String confirmPassword,
    required String displayName,
    required String username,
  }) {
    if (!_isValidEmail(email)) {
      throw const AppException(
        message: 'E-mail inválido.',
        type: AppExceptionType.validation,
      );
    }
    if (displayName.length < 2) {
      throw const AppException(
        message: 'Nome deve ter ao menos 2 caracteres.',
        type: AppExceptionType.validation,
      );
    }
    final usernameError = UsernameRules.validate(username);
    if (usernameError != null) {
      throw AppException(
        message: usernameError,
        type: AppExceptionType.validation,
      );
    }
    if (password.length < 6) {
      throw const AppException(
        message: 'Senha deve ter ao menos 6 caracteres.',
        type: AppExceptionType.validation,
      );
    }
    if (password != confirmPassword) {
      throw const AppException(
        message: 'As senhas não coincidem.',
        type: AppExceptionType.validation,
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }
}
