import '../../../auth/data/datasources/user_firestore_data_source.dart';
import '../../../auth/data/mappers/user_mapper.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../groups/data/datasources/group_firestore_data_source.dart';
import '../../domain/repositories/group_members_repository.dart';

class GroupMembersRepositoryImpl implements GroupMembersRepository {
  GroupMembersRepositoryImpl(this._groups, this._users);

  final GroupFirestoreDataSource _groups;
  final UserFirestoreDataSource _users;

  @override
  Future<List<UserEntity>> fetchMembers({
    required String groupId,
    required String excludeUserId,
  }) async {
    final group = await _groups.getGroup(groupId);
    if (group == null) return [];

    final members = <UserEntity>[];
    for (final memberId in group.memberIds) {
      if (memberId == excludeUserId) continue;
      final user = await _users.getUser(memberId);
      if (user != null) {
        members.add(UserMapper.toEntity(user));
      }
    }
    return members;
  }

  @override
  Future<List<UserEntity>> fetchMembersForGroups({
    required List<String> groupIds,
    required String excludeUserId,
  }) async {
    final seen = <String>{};
    final members = <UserEntity>[];
    for (final groupId in groupIds) {
      final batch = await fetchMembers(groupId: groupId, excludeUserId: excludeUserId);
      for (final user in batch) {
        if (seen.add(user.id)) members.add(user);
      }
    }
    return members;
  }
}
