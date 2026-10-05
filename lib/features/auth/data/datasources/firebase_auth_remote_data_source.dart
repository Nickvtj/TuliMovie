import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/app_exception.dart';

abstract interface class FirebaseAuthRemoteDataSource {
  Stream<User?> authStateChanges();

  User? get currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();
}

class FirebaseAuthRemoteDataSourceImpl implements FirebaseAuthRemoteDataSource {
  FirebaseAuthRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  @override
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  AppException _mapAuthError(FirebaseAuthException e) {
    final message = switch (e.code) {
      'invalid-email' => 'E-mail inválido.',
      'user-disabled' => 'Conta desativada.',
      'user-not-found' => 'Usuário não encontrado.',
      'wrong-password' => 'Senha incorreta.',
      'email-already-in-use' => 'Este e-mail já está cadastrado.',
      'weak-password' => 'Senha muito fraca (mínimo 6 caracteres).',
      'too-many-requests' => 'Muitas tentativas. Aguarde um momento.',
      'network-request-failed' => 'Sem conexão. Verifique a internet.',
      _ => e.message ?? 'Erro de autenticação.',
    };

    return AppException(
      message: message,
      type: AppExceptionType.validation,
      cause: e,
    );
  }
}
