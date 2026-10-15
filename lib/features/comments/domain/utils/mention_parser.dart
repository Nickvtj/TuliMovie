import '../../../auth/domain/utils/username_rules.dart';

/// Encontra `@username` em textos livres (comentários).
abstract final class MentionParser {
  static final pattern = RegExp(
    '@([${UsernameRules.allowedChars}]{${UsernameRules.minLength},${UsernameRules.maxLength}})',
    caseSensitive: false,
  );

  /// Usernames citados, normalizados e sem repetição.
  static Set<String> usernames(String text) {
    return pattern.allMatches(text).map((match) => match.group(1)!.toLowerCase()).toSet();
  }
}
