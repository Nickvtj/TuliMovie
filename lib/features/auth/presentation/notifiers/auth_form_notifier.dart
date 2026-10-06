import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/usecases/login_with_email_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../state/auth_form_state.dart';
import '../utils/auth_validators.dart';

class AuthFormNotifier extends StateNotifier<AuthFormState> {
  AuthFormNotifier({
    required LoginWithEmailUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        super(const AuthFormState());

  final LoginWithEmailUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;

  void openLogin() {
    state = state.copyWith(
      step: AuthFormStep.credentials,
      mode: AuthFormMode.login,
      clearFormError: true,
    );
  }

  void openRegister() {
    state = state.copyWith(
      step: AuthFormStep.credentials,
      mode: AuthFormMode.register,
      clearFormError: true,
    );
  }

  void backToWelcome() {
    state = AuthFormState(
      step: AuthFormStep.welcome,
      mode: state.mode,
      email: state.email,
    );
  }

  void toggleMode() {
    state = state.copyWith(
      mode: state.isRegister ? AuthFormMode.login : AuthFormMode.register,
      clearFormError: true,
    );
  }

  void onEmailChanged(String value) {
    state = state.copyWith(
      email: value,
      emailError: AuthValidators.email(value),
      clearFormError: true,
    );
  }

  void onPasswordChanged(String value) {
    state = state.copyWith(
      password: value,
      passwordError: AuthValidators.password(value),
      confirmPasswordError: state.isRegister
          ? AuthValidators.confirmPassword(state.confirmPassword, value)
          : null,
      clearFormError: true,
    );
  }

  void onConfirmPasswordChanged(String value) {
    state = state.copyWith(
      confirmPassword: value,
      confirmPasswordError: AuthValidators.confirmPassword(value, state.password),
      clearFormError: true,
    );
  }

  void onDisplayNameChanged(String value) {
    state = state.copyWith(
      displayName: value,
      displayNameError: AuthValidators.displayName(value),
      clearFormError: true,
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);
  }

  Future<bool> submit() async {
    final validated = _validateAll();
    state = validated;
    if (!validated.canSubmit) return false;

    state = state.copyWith(isSubmitting: true, clearFormError: true);

    try {
      if (state.isRegister) {
        await _registerUseCase(
          email: state.email,
          password: state.password,
          confirmPassword: state.confirmPassword,
          displayName: state.displayName,
        );
      } else {
        await _loginUseCase(
          email: state.email,
          password: state.password,
        );
      }
      state = state.copyWith(isSubmitting: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, formError: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        formError: 'Algo deu errado. Tente novamente.',
      );
      return false;
    }
  }

  AuthFormState _validateAll() {
    return state.copyWith(
      emailError: AuthValidators.email(state.email),
      passwordError: AuthValidators.password(state.password),
      confirmPasswordError: state.isRegister
          ? AuthValidators.confirmPassword(state.confirmPassword, state.password)
          : null,
      displayNameError:
          state.isRegister ? AuthValidators.displayName(state.displayName) : null,
    );
  }
}
