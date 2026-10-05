import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/auth/presentation/utils/auth_validators.dart';

void main() {
  test('valida e-mail', () {
    expect(AuthValidators.email(''), isNotNull);
    expect(AuthValidators.email('a@b.com'), isNull);
  });

  test('valida confirmação de senha', () {
    expect(AuthValidators.confirmPassword('123456', '123456'), isNull);
    expect(AuthValidators.confirmPassword('123', '123456'), isNotNull);
  });
}
