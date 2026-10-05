import '../../../auth/data/datasources/user_firestore_data_source.dart';
import '../../../auth/data/mappers/user_mapper.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/group_members_repository.dart';

class GroupMembersRepositoryImpl implements GroupMembersRepository {
  GroupMembersRepositoryImpl(this._users);

  final UserFirestoreDataSource _users;

  @override
  Future<List<UserEntity>> fetchMembers({required String excludeUserId}) async {
    final models = await _users.fetchAllUsers(excludeUserId: excludeUserId);
    return models.map(UserMapper.toEntity).toList();
  }
}
