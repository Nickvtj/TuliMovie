import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Stream<UserEntity?> watchAuthState();

  Future<UserEntity?> getCurrentUser();

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

  Future<void> signOut();
}
