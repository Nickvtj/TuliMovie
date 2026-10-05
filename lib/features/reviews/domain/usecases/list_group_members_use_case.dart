import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/group_members_repository.dart';

class ListGroupMembersUseCase {
  ListGroupMembersUseCase(this._repository);

  final GroupMembersRepository _repository;

  Future<List<UserEntity>> call({required String excludeUserId}) {
    return _repository.fetchMembers(excludeUserId: excludeUserId);
  }
}
