import '../../../auth/domain/entities/user_entity.dart';

abstract interface class SocialRepository {
  Future<List<UserEntity>> searchUsers(String prefix);

  Future<void> follow({required String userId, required String targetId});

  Future<void> unfollow({required String userId, required String targetId});

  /// `true` enquanto [userId] segue [targetId].
  Stream<bool> watchIsFollowing({required String userId, required String targetId});

  Stream<Set<String>> watchFollowingIds(String userId);

  Future<int> countFollowers(String userId);

  Future<int> countFollowing(String userId);

  Future<List<UserEntity>> fetchFollowers(String userId);

  Future<List<UserEntity>> fetchFollowing(String userId);
}
