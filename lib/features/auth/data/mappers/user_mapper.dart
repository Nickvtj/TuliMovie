import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract final class UserMapper {
  static UserEntity toEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      displayName: model.displayName,
      username: model.username,
      photoUrl: model.photoUrl,
      bio: model.bio,
      favoriteMovies: model.favoriteMovies,
      favoriteActors: model.favoriteActors,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static UserModel toModel(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      username: entity.username,
      photoUrl: entity.photoUrl,
      bio: entity.bio,
      favoriteMovies: entity.favoriteMovies,
      favoriteActors: entity.favoriteActors,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
