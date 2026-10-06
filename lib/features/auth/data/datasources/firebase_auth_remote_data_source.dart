import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

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
      : _authOverride = firebaseAuth;

  final FirebaseAuth? _authOverride;

  FirebaseAuth? get _auth {
    if (_authOverride != null) return _authOverride;
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance;
  }

  AppException get _firebaseNotConfigured => const AppException(
        message:
            'Firebase não configurado. Rode: flutterfire configure',
        type: AppExceptionType.unknown,
      );

  @override
  Stream<User?> authStateChanges() {
    final auth = _auth;
    if (auth == null) return Stream.value(null);
    return auth.authStateChanges();
  }

  @override
  User? get currentUser => _auth?.currentUser;

  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) throw _firebaseNotConfigured;
    try {
      return await auth.signInWithEmailAndPassword(
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
    final auth = _auth;
    if (auth == null) throw _firebaseNotConfigured;
    try {
      final credential = await auth.createUserWithEmailAndPassword(
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
    final auth = _auth;
    if (auth == null) return;
    try {
      await auth.signOut();
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
      'invalid-credential' => 'E-mail ou senha incorretos.',
      'email-already-in-use' => 'Este e-mail já está cadastrado. Tente Entrar.',
      'weak-password' => 'Senha muito fraca (mínimo 6 caracteres).',
      'too-many-requests' => 'Muitas tentativas. Aguarde um momento.',
      'network-request-failed' => 'Sem conexão. Verifique a internet.',
      'configuration-not-found' =>
        'Authentication ainda não foi ativado no projeto. Abra: '
            'console.firebase.google.com/project/tulimovie/authentication → '
            'Começar → Sign-in method → E-mail/senha → Ativar.',
      'operation-not-allowed' =>
        'Cadastro por e-mail desativado. No Console Firebase: Authentication → '
            'Sign-in method → E-mail/senha → Ativar.',
      'admin-restricted-operation' =>
        'Operação bloqueada pelo Firebase. Ative E-mail/senha em Authentication.',
      'invalid-api-key' => 'Chave da API inválida. Rode flutterfire configure de novo.',
      'app-not-authorized' =>
        'App Web não autorizado. Confira o domínio localhost no Console Firebase.',
      _ => _authMessageFallback(e),
    };

    return AppException(
      message: message,
      type: AppExceptionType.validation,
      cause: e,
    );
  }

  /// A Web/API às vezes devolve `message: "Error"` — preferimos texto útil + código.
  static String _authMessageFallback(FirebaseAuthException e) {
    final raw = e.message?.trim();
    if (raw != null && raw.isNotEmpty && raw.toLowerCase() != 'error') {
      return raw;
    }
    return 'Falha na autenticação (${e.code}). '
        'Confira Authentication → E-mail/senha ativado no Console Firebase.';
  }
}
