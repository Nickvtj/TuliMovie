import '../entities/favorite_actor_entity.dart';
import '../entities/favorite_movie_entity.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Stream<UserEntity?> watchAuthState();

  Future<UserEntity?> getCurrentUser();

  /// Há sessão no Firebase Auth (sem ler o perfil no Firestore).
  bool get isSignedIn;

  /// Perfil público em tempo real (`users/{userId}`).
  Stream<UserEntity?> watchUserProfile(String userId);

  Future<UserEntity> loginWithEmail({
    required String email,
    required String password,
  });

  Future<UserEntity> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String username,
  });

  Future<void> claimUsername({
    required String userId,
    required String username,
  });

  /// Atualiza só os campos informados do perfil público.
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? photoUrl,
    List<FavoriteMovieEntity>? favoriteMovies,
    List<FavoriteActorEntity>? favoriteActors,
  });

  Future<void> signOut();
}
