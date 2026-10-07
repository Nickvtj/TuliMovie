import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_with_email_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import '../notifiers/auth_form_notifier.dart';
import '../state/auth_form_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => sl<AuthRepository>());

final loginWithEmailUseCaseProvider = Provider<LoginWithEmailUseCase>(
  (ref) => LoginWithEmailUseCase(ref.watch(authRepositoryProvider)),
);

final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);

final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => SignOutUseCase(ref.watch(authRepositoryProvider), sl()),
);

/// Session management — stream único de sessão Firebase + perfil Firestore.
final authSessionProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).watchAuthState();
});

final authFormNotifierProvider =
    StateNotifierProvider<AuthFormNotifier, AuthFormState>((ref) {
  return AuthFormNotifier(
    loginUseCase: ref.watch(loginWithEmailUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    rememberMeStorage: sl(),
  );
});
