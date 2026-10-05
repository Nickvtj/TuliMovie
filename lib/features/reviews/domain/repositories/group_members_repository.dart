import '../../../auth/domain/entities/user_entity.dart';

abstract interface class GroupMembersRepository {
  Future<List<UserEntity>> fetchMembers({required String excludeUserId});
}
