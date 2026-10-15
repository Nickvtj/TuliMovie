import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/follow_status_entity.dart';
import '../../domain/repositories/social_repository.dart';
import '../../domain/usecases/follow_user_use_case.dart';
import '../../domain/usecases/search_users_use_case.dart';
import '../../domain/usecases/unfollow_user_use_case.dart';
import '../notifiers/user_search_notifier.dart';

typedef FollowPair = ({String userId, String targetId});

final socialRepositoryProvider = Provider<SocialRepository>((ref) => sl<SocialRepository>());

final searchUsersUseCaseProvider = Provider((ref) => sl<SearchUsersUseCase>());

final followUserUseCaseProvider = Provider((ref) => sl<FollowUserUseCase>());

final unfollowUserUseCaseProvider = Provider((ref) => sl<UnfollowUserUseCase>());

final userSearchNotifierProvider =
    StateNotifierProvider.autoDispose<UserSearchNotifier, UserSearchState>((ref) {
  return UserSearchNotifier(
    ref.watch(searchUsersUseCaseProvider),
    currentUserId: ref.watch(authSessionProvider).valueOrNull?.id ?? '',
  );
});

final isFollowingProvider = StreamProvider.autoDispose.family<bool, FollowPair>((ref, pair) {
  return ref
      .watch(socialRepositoryProvider)
      .watchIsFollowing(userId: pair.userId, targetId: pair.targetId);
});

/// Relação do usuário logado com [targetId]; `null` enquanto carrega.
final followStatusProvider =
    Provider.autoDispose.family<FollowStatusEntity?, String>((ref, targetId) {
  final me = ref.watch(authSessionProvider).valueOrNull?.id;
  if (me == null || me == targetId) return const FollowStatusEntity();

  final isFollowing = ref.watch(isFollowingProvider((userId: me, targetId: targetId)));
  final followsYou = ref.watch(isFollowingProvider((userId: targetId, targetId: me)));
  if (isFollowing.isLoading || followsYou.isLoading) return null;

  return FollowStatusEntity(
    isFollowing: isFollowing.valueOrNull ?? false,
    followsYou: followsYou.valueOrNull ?? false,
  );
});

final followersCountProvider = FutureProvider.autoDispose.family<int, String>((ref, userId) {
  return ref.watch(socialRepositoryProvider).countFollowers(userId);
});

final followingCountProvider = FutureProvider.autoDispose.family<int, String>((ref, userId) {
  return ref.watch(socialRepositoryProvider).countFollowing(userId);
});

final followersProvider =
    FutureProvider.autoDispose.family<List<UserEntity>, String>((ref, userId) {
  return ref.watch(socialRepositoryProvider).fetchFollowers(userId);
});

final followingProvider =
    FutureProvider.autoDispose.family<List<UserEntity>, String>((ref, userId) {
  return ref.watch(socialRepositoryProvider).fetchFollowing(userId);
});

/// Segue ou deixa de seguir [targetId] e atualiza contadores/listas afetados.
Future<void> toggleFollow(WidgetRef ref, String targetId) async {
  final me = ref.read(authSessionProvider).valueOrNull?.id;
  final status = ref.read(followStatusProvider(targetId));
  if (me == null || status == null) return;

  if (status.isFollowing) {
    await ref.read(unfollowUserUseCaseProvider).call(userId: me, targetId: targetId);
  } else {
    await ref.read(followUserUseCaseProvider).call(userId: me, targetId: targetId);
  }

  ref
    ..invalidate(followersCountProvider(targetId))
    ..invalidate(followersProvider(targetId))
    ..invalidate(followingCountProvider(me))
    ..invalidate(followingProvider(me));
}
