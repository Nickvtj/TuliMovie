import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/auth/domain/utils/username_rules.dart';

void main() {
  test('normaliza @, espaços e maiúsculas', () {
    expect(UsernameRules.normalize('  @Nick.Vieira '), 'nick.vieira');
  });

  test('aceita letras, números, ponto e underline', () {
    expect(UsernameRules.validate('nick_vieira.92'), isNull);
  });

  test('rejeita tamanho fora dos limites', () {
    expect(UsernameRules.validate(''), isNotNull);
    expect(UsernameRules.validate('ab'), isNotNull);
    expect(UsernameRules.validate('a' * 21), isNotNull);
  });

  test('rejeita caracteres inválidos', () {
    expect(UsernameRules.validate('nick vieira'), isNotNull);
    expect(UsernameRules.validate('nick-vieira'), isNotNull);
    expect(UsernameRules.validate('joão'), isNotNull);
  });
}
