import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/group_firestore_data_source.dart';
import '../mappers/group_mapper.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl(this._dataSource);

  final GroupFirestoreDataSource _dataSource;

  @override
  Future<GroupEntity> createGroup({required String name, required String userId}) async {
    final model = await _dataSource.createGroup(name: name, createdBy: userId);
    return GroupMapper.toEntity(model);
  }

  @override
  Future<GroupEntity?> joinByInviteCode({required String code, required String userId}) async {
    final model = await _dataSource.findByInviteCode(code);
    if (model == null) return null;
    if (!model.memberIds.contains(userId)) {
      await _dataSource.addMember(groupId: model.id, userId: userId);
    }
    final updated = await _dataSource.getGroup(model.id);
    return updated == null ? null : GroupMapper.toEntity(updated);
  }

  @override
  Future<GroupEntity?> getGroup(String groupId) async {
    final model = await _dataSource.getGroup(groupId);
    return model == null ? null : GroupMapper.toEntity(model);
  }

  @override
  Stream<List<GroupEntity>> watchUserGroups(String userId) {
    return _dataSource.watchGroupsForUser(userId).map(GroupMapper.toEntityList);
  }

  @override
  Future<void> addMember({required String groupId, required String userId}) {
    return _dataSource.addMember(groupId: groupId, userId: userId);
  }
}
