import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/data/datasources/user_firestore_data_source.dart';
import '../../../auth/data/mappers/user_mapper.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/follow_firestore_data_source.dart';

class SocialRepositoryImpl implements SocialRepository {
  SocialRepositoryImpl({
    required FollowFirestoreDataSource follows,
    required UserFirestoreDataSource users,
  })  : _follows = follows,
        _users = users;

  final FollowFirestoreDataSource _follows;
  final UserFirestoreDataSource _users;

  @override
  Future<List<UserEntity>> searchUsers(String prefix) async {
    final models = await _users.searchUsers(prefix);
    return models.map(UserMapper.toEntity).toList();
  }

  @override
  Future<void> follow({required String userId, required String targetId}) {
    return _guard(() => _follows.follow(userId: userId, targetId: targetId));
  }

  @override
  Future<void> unfollow({required String userId, required String targetId}) {
    return _guard(() => _follows.unfollow(userId: userId, targetId: targetId));
  }

  @override
  Stream<bool> watchIsFollowing({required String userId, required String targetId}) {
    return _follows.watchIsFollowing(userId: userId, targetId: targetId);
  }

  @override
  Future<int> countFollowers(String userId) => _guard(() => _follows.countFollowers(userId));

  @override
  Future<int> countFollowing(String userId) => _guard(() => _follows.countFollowing(userId));

  @override
  Future<List<UserEntity>> fetchFollowers(String userId) {
    return _guard(() async => _usersInOrder(await _follows.fetchFollowerIds(userId)));
  }

  @override
  Future<List<UserEntity>> fetchFollowing(String userId) {
    return _guard(() async => _usersInOrder(await _follows.fetchFollowingIds(userId)));
  }

  /// Mantém a ordem dos ids (mais recentes primeiro); `whereIn` não garante ordem.
  Future<List<UserEntity>> _usersInOrder(List<String> userIds) async {
    final models = await _users.fetchUsersByIds(userIds);
    final byId = {for (final model in models) model.id: model};
    return userIds
        .map((id) => byId[id])
        .whereType<UserModel>()
        .map(UserMapper.toEntity)
        .toList();
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (e) {
      throw AppException(
        message: e.message ?? 'Erro no Firestore (${e.code}).',
        type: AppExceptionType.server,
        cause: e,
      );
    }
  }
}
