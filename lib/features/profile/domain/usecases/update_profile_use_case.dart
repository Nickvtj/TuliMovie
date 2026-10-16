import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/entities/favorite_actor_entity.dart';
import '../../../auth/domain/entities/favorite_movie_entity.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

/// Edição do perfil público: nome, bio, avatar e Top 4 (filmes / atores).
class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);

  static const nameMinLength = 2;
  static const nameMaxLength = 40;
  static const bioMaxLength = 160;
  static const favoritesMax = 4;

  final AuthRepository _repository;

  Future<void> call({
    required String userId,
    String? displayName,
    String? bio,
    String? photoUrl,
    List<FavoriteMovieEntity>? favoriteMovies,
    List<FavoriteActorEntity>? favoriteActors,
  }) async {
    final name = displayName?.trim();
    final about = bio?.trim();

    if (name != null && (name.length < nameMinLength || name.length > nameMaxLength)) {
      throw const AppException(
        message: 'O nome deve ter entre $nameMinLength e $nameMaxLength caracteres.',
        type: AppExceptionType.validation,
      );
    }
    if (about != null && about.length > bioMaxLength) {
      throw const AppException(
        message: 'A bio pode ter no máximo $bioMaxLength caracteres.',
        type: AppExceptionType.validation,
      );
    }
    if ((favoriteMovies?.length ?? 0) > favoritesMax ||
        (favoriteActors?.length ?? 0) > favoritesMax) {
      throw const AppException(
        message: 'Escolha no máximo $favoritesMax favoritos.',
        type: AppExceptionType.validation,
      );
    }

    try {
      await _repository.updateProfile(
        userId: userId,
        displayName: name,
        bio: about,
        photoUrl: photoUrl,
        favoriteMovies: favoriteMovies,
        favoriteActors: favoriteActors,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Não foi possível salvar o perfil.', cause: e);
    }
  }
}
