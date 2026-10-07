import '../../../auth/domain/entities/user_entity.dart';

abstract interface class GroupMembersRepository {
  Future<List<UserEntity>> fetchMembers({
    required String groupId,
    required String excludeUserId,
  });

  Future<List<UserEntity>> fetchMembersForGroups({
    required List<String> groupIds,
    required String excludeUserId,
  });
}
