import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract final class UserMapper {
  static UserEntity toEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      displayName: model.displayName,
      photoUrl: model.photoUrl,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static UserModel toModel(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
