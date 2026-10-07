import '../../../../core/di/injection.dart';
import '../../data/local/auth_remember_me_storage.dart';
import '../../domain/repositories/auth_repository.dart';

/// Garante que sessões sem "lembrar" ou expiradas não restaurem o usuário automaticamente.
Future<void> enforceAuthSessionPolicy() async {
  final authRepository = sl<AuthRepository>();
  final storage = sl<AuthRememberMeStorage>();

  final user = await authRepository.getCurrentUser();
  if (user == null) return;

  final invalidate = await storage.shouldInvalidatePersistedSession();
  if (!invalidate) return;

  await authRepository.signOut();
  await storage.clearSession();
}
