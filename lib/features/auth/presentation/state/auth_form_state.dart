import 'package:equatable/equatable.dart';

enum AuthFormMode { login, register }

class AuthFormState extends Equatable {
  const AuthFormState({
    this.mode = AuthFormMode.login,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.displayName = '',
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.displayNameError,
    this.isSubmitting = false,
    this.formError,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
  });

  final AuthFormMode mode;
  final String email;
  final String password;
  final String confirmPassword;
  final String displayName;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? displayNameError;
  final bool isSubmitting;
  final String? formError;
  final bool obscurePassword;
  final bool obscureConfirmPassword;

  bool get isRegister => mode == AuthFormMode.register;

  bool get canSubmit {
    if (isSubmitting) return false;
    if (emailError != null || passwordError != null) return false;
    if (isRegister && (confirmPasswordError != null || displayNameError != null)) {
      return false;
    }
    if (email.trim().isEmpty || password.isEmpty) return false;
    if (isRegister && (confirmPassword.isEmpty || displayName.trim().isEmpty)) {
      return false;
    }
    return true;
  }

  AuthFormState copyWith({
    AuthFormMode? mode,
    String? email,
    String? password,
    String? confirmPassword,
    String? displayName,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? displayNameError,
    bool? isSubmitting,
    String? formError,
    bool clearFormError = false,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
  }) {
    return AuthFormState(
      mode: mode ?? this.mode,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      displayName: displayName ?? this.displayName,
      emailError: emailError ?? this.emailError,
      passwordError: passwordError ?? this.passwordError,
      confirmPasswordError: confirmPasswordError ?? this.confirmPasswordError,
      displayNameError: displayNameError ?? this.displayNameError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      formError: clearFormError ? null : formError ?? this.formError,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        email,
        password,
        confirmPassword,
        displayName,
        emailError,
        passwordError,
        confirmPasswordError,
        displayNameError,
        isSubmitting,
        formError,
        obscurePassword,
        obscureConfirmPassword,
      ];
}
