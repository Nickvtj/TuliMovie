import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/iterable_extensions.dart';
import '../../../tools/data/datasources/watchlist_firestore_data_source.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../feed/data/datasources/review_firestore_data_source.dart';
import '../../data/datasources/group_firestore_data_source.dart';
import '../../data/local/active_group_storage.dart';
import '../../data/repositories/group_repository_impl.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/usecases/ensure_active_group_use_case.dart';

final groupFirestoreProvider = Provider((_) => GroupFirestoreDataSource());

final groupRepositoryProvider = Provider<GroupRepository>(
  (ref) => GroupRepositoryImpl(ref.watch(groupFirestoreProvider)),
);

final activeGroupStorageProvider = Provider((_) => ActiveGroupStorage());

final ensureActiveGroupUseCaseProvider = Provider(
  (ref) => EnsureActiveGroupUseCase(
    groups: ref.watch(groupRepositoryProvider),
    storage: ref.watch(activeGroupStorageProvider),
    reviews: sl<ReviewFirestoreDataSource>(),
    watchlist: sl<WatchlistFirestoreDataSource>(),
  ),
);

final activeGroupIdProvider = StateProvider<String?>((ref) => null);

final userGroupsProvider = StreamProvider<List<GroupEntity>>((ref) {
  final user = ref.watch(authSessionProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(groupRepositoryProvider).watchUserGroups(user.id);
});

final activeGroupProvider = Provider<GroupEntity?>((ref) {
  final id = ref.watch(activeGroupIdProvider);
  final groups = ref.watch(userGroupsProvider).valueOrNull ?? [];
  if (id == null) return groups.isNotEmpty ? groups.first : null;
  return groups.where((g) => g.id == id).firstOrNull ?? groups.firstOrNull;
});

/// Inicializa turma após login — chamar no shell ou auth gate.
final groupBootstrapProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(authSessionProvider).valueOrNull;
  if (user == null) return;

  final group = await ref.read(ensureActiveGroupUseCaseProvider).call(
        userId: user.id,
        displayName: user.displayName,
      );
  ref.read(activeGroupIdProvider.notifier).state = group.id;
});
