import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_remote_data_source.dart';
import '../datasources/user_firestore_data_source.dart';
import '../mappers/user_mapper.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required FirebaseAuthRemoteDataSource authRemote,
    required UserFirestoreDataSource userFirestore,
  })  : _authRemote = authRemote,
        _userFirestore = userFirestore;

  final FirebaseAuthRemoteDataSource _authRemote;
  final UserFirestoreDataSource _userFirestore;

  @override
  Stream<UserEntity?> watchAuthState() {
    return _authRemote.authStateChanges().asyncMap(_resolveUser);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _authRemote.currentUser;
    if (firebaseUser == null) return null;
    return _resolveUser(firebaseUser);
  }

  @override
  Future<UserEntity> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _authRemote.signInWithEmail(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw const AppException(message: 'Sessão inválida após login.');
    }
    final entity = await _resolveUser(user);
    if (entity == null) {
      throw const AppException(message: 'Perfil não encontrado após login.');
    }
    return entity;
  }

  @override
  Future<UserEntity> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _authRemote.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw const AppException(message: 'Conta criada, mas sessão indisponível.');
    }

    final model = UserModel(
      id: firebaseUser.uid,
      email: email,
      displayName: displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _userFirestore.upsertUser(model);
    return UserMapper.toEntity(model);
  }

  @override
  Future<void> signOut() => _authRemote.signOut();

  Future<UserEntity?> _resolveUser(User? firebaseUser) async {
    if (firebaseUser == null) return null;

    final uid = firebaseUser.uid;
    final email = firebaseUser.email ?? '';
    final displayNameFallback = firebaseUser.displayName ?? email.split('@').first;

    UserEntity entityFromAuth() => UserEntity(
          id: uid,
          email: email,
          displayName: displayNameFallback,
          photoUrl: firebaseUser.photoURL,
        );

    try {
      final stored = await _userFirestore.getUser(uid);
      if (stored != null) {
        return UserMapper.toEntity(stored);
      }

      final bootstrap = UserModel(
        id: uid,
        email: email,
        displayName: displayNameFallback,
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _userFirestore.upsertUser(bootstrap);
      return UserMapper.toEntity(bootstrap);
    } on AppException catch (e) {
      if (_allowAuthOnlyFallback(e)) {
        return entityFromAuth();
      }
      rethrow;
    } catch (e) {
      throw AppException(message: 'Erro ao carregar perfil.', cause: e);
    }
  }

  /// Auth OK, Firestore indisponível — entra no app; perfil sincroniza depois.
  bool _allowAuthOnlyFallback(AppException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('offline') ||
        msg.contains('indisponível') ||
        msg.contains('bloqueado') ||
        msg.contains('firestore offline')) {
      return true;
    }
    if (e.cause is FirebaseException) {
      final code = (e.cause! as FirebaseException).code;
      return code == 'unavailable';
    }
    return false;
  }
}
