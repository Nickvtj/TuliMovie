import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/profile_dashboard_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_dashboard_use_case.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => sl<ProfileRepository>(),
);

final getProfileDashboardUseCaseProvider = Provider(
  (ref) => GetProfileDashboardUseCase(ref.watch(profileRepositoryProvider)),
);

final profileDashboardProvider = FutureProvider<ProfileDashboardEntity>((ref) async {
  final user = ref.watch(authSessionProvider).valueOrNull;
  if (user == null) {
    throw StateError('Usuário não autenticado');
  }
  return ref.watch(getProfileDashboardUseCaseProvider).call(user);
});
