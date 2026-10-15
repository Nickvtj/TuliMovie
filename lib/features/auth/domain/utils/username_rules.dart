/// Regras do @username — fonte única para use cases e validadores de formulário.
abstract final class UsernameRules {
  static const minLength = 3;
  static const maxLength = 20;

  static final _allowed = RegExp(r'^[a-z0-9._]+$');

  /// Remove `@` inicial e espaços; sempre minúsculo.
  static String normalize(String value) {
    final trimmed = value.trim().toLowerCase();
    return trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
  }

  /// Mensagem de erro ou `null` se válido. Espera valor já normalizado.
  static String? validate(String username) {
    if (username.isEmpty) return 'Escolha seu @.';
    if (username.length < minLength) return 'Mínimo de $minLength caracteres.';
    if (username.length > maxLength) return 'Máximo de $maxLength caracteres.';
    if (!_allowed.hasMatch(username)) return 'Use só letras, números, ponto e _.';
    return null;
  }
}
