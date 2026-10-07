import '../../domain/entities/group_entity.dart';
import '../models/group_model.dart';

abstract final class GroupMapper {
  static GroupEntity toEntity(GroupModel model) {
    return GroupEntity(
      id: model.id,
      name: model.name,
      inviteCode: model.inviteCode,
      memberIds: model.memberIds,
      createdBy: model.createdBy,
      createdAt: model.createdAt,
    );
  }

  static List<GroupEntity> toEntityList(List<GroupModel> models) =>
      models.map(toEntity).toList();
}
