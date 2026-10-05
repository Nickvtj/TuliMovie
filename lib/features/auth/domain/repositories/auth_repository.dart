import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Stream<UserEntity?> watchAuthState();

  Future<UserEntity?> getCurrentUser();

  Future<UserEntity> loginWithEmail({
    required String email,
    required String password,
  });

  Future<UserEntity> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();
}
