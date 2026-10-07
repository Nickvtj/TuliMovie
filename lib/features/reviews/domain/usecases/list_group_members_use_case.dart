import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/group_members_repository.dart';

class ListGroupMembersUseCase {
  ListGroupMembersUseCase(this._repository);

  final GroupMembersRepository _repository;

  Future<List<UserEntity>> call({
    required String groupId,
    required String excludeUserId,
  }) {
    return _repository.fetchMembers(groupId: groupId, excludeUserId: excludeUserId);
  }

  Future<List<UserEntity>> forGroups({
    required List<String> groupIds,
    required String excludeUserId,
  }) {
    return _repository.fetchMembersForGroups(groupIds: groupIds, excludeUserId: excludeUserId);
  }
}
