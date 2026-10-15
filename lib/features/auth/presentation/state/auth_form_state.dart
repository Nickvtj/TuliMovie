import 'package:equatable/equatable.dart';

enum AuthFormMode { login, register }

enum AuthFormStep { welcome, credentials }

/// Distingue "não passou parâmetro" de "limpar erro" em [AuthFormState.copyWith].
const _copyWithUnset = Object();

class AuthFormState extends Equatable {
  const AuthFormState({
    this.step = AuthFormStep.welcome,
    this.mode = AuthFormMode.login,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.displayName = '',
    this.username = '',
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.displayNameError,
    this.usernameError,
    this.isSubmitting = false,
    this.formError,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.rememberMe = true,
  });

  final AuthFormStep step;
  final AuthFormMode mode;
  final String email;
  final String password;
  final String confirmPassword;
  final String displayName;
  final String username;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? displayNameError;
  final String? usernameError;
  final bool isSubmitting;
  final String? formError;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool rememberMe;

  bool get isRegister => mode == AuthFormMode.register;

  bool get isWelcome => step == AuthFormStep.welcome;

  bool get canSubmit {
    if (step != AuthFormStep.credentials) return false;
    if (isSubmitting) return false;
    if (emailError != null || passwordError != null) return false;
    if (isRegister &&
        (confirmPasswordError != null || displayNameError != null || usernameError != null)) {
      return false;
    }
    if (email.trim().isEmpty || password.isEmpty) return false;
    if (isRegister &&
        (confirmPassword.isEmpty || displayName.trim().isEmpty || username.trim().isEmpty)) {
      return false;
    }
    return true;
  }

  AuthFormState copyWith({
    AuthFormStep? step,
    AuthFormMode? mode,
    String? email,
    String? password,
    String? confirmPassword,
    String? displayName,
    String? username,
    Object? emailError = _copyWithUnset,
    Object? passwordError = _copyWithUnset,
    Object? confirmPasswordError = _copyWithUnset,
    Object? displayNameError = _copyWithUnset,
    Object? usernameError = _copyWithUnset,
    bool? isSubmitting,
    String? formError,
    bool clearFormError = false,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? rememberMe,
  }) {
    return AuthFormState(
      step: step ?? this.step,
      mode: mode ?? this.mode,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      emailError:
          identical(emailError, _copyWithUnset) ? this.emailError : emailError as String?,
      passwordError: identical(passwordError, _copyWithUnset)
          ? this.passwordError
          : passwordError as String?,
      confirmPasswordError: identical(confirmPasswordError, _copyWithUnset)
          ? this.confirmPasswordError
          : confirmPasswordError as String?,
      displayNameError: identical(displayNameError, _copyWithUnset)
          ? this.displayNameError
          : displayNameError as String?,
      usernameError: identical(usernameError, _copyWithUnset)
          ? this.usernameError
          : usernameError as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      formError: clearFormError ? null : formError ?? this.formError,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  @override
  List<Object?> get props => [
        step,
        mode,
        email,
        password,
        confirmPassword,
        displayName,
        username,
        emailError,
        passwordError,
        confirmPasswordError,
        displayNameError,
        usernameError,
        isSubmitting,
        formError,
        obscurePassword,
        obscureConfirmPassword,
        rememberMe,
      ];
}
