import 'package:shared_preferences/shared_preferences.dart';

/// Persistência da opção "Lembrar por 30 dias" após login/cadastro.
class AuthRememberMeStorage {
  static const _rememberMeKey = 'auth_remember_me';
  static const _validUntilMsKey = 'auth_remember_until_ms';

  static const _sessionDuration = Duration(days: 30);

  Future<bool> loadRememberMeDefault() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? true;
  }

  Future<void> persistSessionAfterAuth({required bool rememberMe}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
    if (rememberMe) {
      final until = DateTime.now().add(_sessionDuration).millisecondsSinceEpoch;
      await prefs.setInt(_validUntilMsKey, until);
    } else {
      await prefs.remove(_validUntilMsKey);
    }
  }

  /// Retorna true se a sessão Firebase existente deve ser encerrada no cold start.
  Future<bool> shouldInvalidatePersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberMeKey);
    if (remember != true) return true;

    final untilMs = prefs.getInt(_validUntilMsKey);
    if (untilMs == null) return true;

    return DateTime.now().millisecondsSinceEpoch > untilMs;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_validUntilMsKey);
  }
}
