import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/auth/presentation/state/auth_form_state.dart';

void main() {
  test('copyWith limpa erros quando validação passa (null)', () {
    const withErrors = AuthFormState(
      emailError: 'E-mail inválido.',
      passwordError: 'Mínimo de 6 caracteres.',
    );

    final cleared = withErrors.copyWith(
      emailError: null,
      passwordError: null,
    );

    expect(cleared.emailError, isNull);
    expect(cleared.passwordError, isNull);
  });

  test('canSubmit false na tela de boas-vindas', () {
    const welcome = AuthFormState(step: AuthFormStep.welcome);
    expect(welcome.canSubmit, isFalse);
  });

  test('copyWith mantém erro se parâmetro omitido', () {
    const withErrors = AuthFormState(emailError: 'E-mail inválido.');

    final same = withErrors.copyWith(email: 'a@b.com');

    expect(same.emailError, 'E-mail inválido.');
  });
}
