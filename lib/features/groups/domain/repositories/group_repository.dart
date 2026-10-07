import '../entities/group_entity.dart';

abstract interface class GroupRepository {
  Future<GroupEntity> createGroup({required String name, required String userId});

  Future<GroupEntity?> joinByInviteCode({required String code, required String userId});

  Future<GroupEntity?> getGroup(String groupId);

  Stream<List<GroupEntity>> watchUserGroups(String userId);

  Future<void> addMember({required String groupId, required String userId});
}
