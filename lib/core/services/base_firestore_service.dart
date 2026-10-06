import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/firebase_firestore_access.dart';
import '../errors/app_exception.dart';
import 'i_base_firestore_service.dart';

/// Implementação única e tipada via callbacks [fromJson]/[toJson].
class BaseFirestoreService implements IBaseFirestoreService {
  BaseFirestoreService({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  CollectionReference<Map<String, dynamic>> _collection(String path) {
    return FirebaseFirestoreAccess.require(override: _firestoreOverride).collection(path);
  }

  @override
  Future<void> create<T>({
    required String collectionPath,
    required String documentId,
    required T data,
    required Map<String, dynamic> Function(T value) toJson,
  }) async {
    try {
      await _collection(collectionPath).doc(documentId).set(toJson(data));
    } on FirebaseException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<T?> read<T>({
    required String collectionPath,
    required String documentId,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    try {
      final snap = await _collection(collectionPath).doc(documentId).get();
      if (!snap.exists || snap.data() == null) return null;
      return fromJson({...snap.data()!, 'id': snap.id});
    } on FirebaseException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<void> update<T>({
    required String collectionPath,
    required String documentId,
    required T data,
    required Map<String, dynamic> Function(T value) toJson,
    bool merge = true,
  }) async {
    try {
      await _collection(collectionPath)
          .doc(documentId)
          .set(toJson(data), SetOptions(merge: merge));
    } on FirebaseException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<void> delete({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      await _collection(collectionPath).doc(documentId).delete();
    } on FirebaseException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<List<T>> query<T>({
    required String collectionPath,
    required T Function(Map<String, dynamic> json) fromJson,
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>> ref)?
        queryBuilder,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection(collectionPath);
      if (queryBuilder != null) query = queryBuilder(_collection(collectionPath));
      if (limit != null) query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } on FirebaseException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Stream<T?> watchDocument<T>({
    required String collectionPath,
    required String documentId,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    return _collection(collectionPath).doc(documentId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return fromJson({...snap.data()!, 'id': snap.id});
    });
  }

  @override
  Stream<List<T>> watchCollection<T>({
    required String collectionPath,
    required T Function(Map<String, dynamic> json) fromJson,
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>> ref)?
        queryBuilder,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _collection(collectionPath);
    if (queryBuilder != null) query = queryBuilder(_collection(collectionPath));
    if (limit != null) query = query.limit(limit);

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  AppException _mapFirebaseError(FirebaseException e) {
    final message = switch (e.code) {
      'permission-denied' =>
        'Sem permissão no Firestore. Crie o banco e publique as regras (firestore.rules).',
      'unavailable' =>
        'Firestore offline ou bloqueado. Teste outro navegador ou desative adblock.',
      'failed-precondition' =>
        'Firestore não configurado. Console → Firestore → Criar banco de dados.',
      'not-found' => 'Documento não encontrado no Firestore.',
      _ => _firestoreMessageFallback(e),
    };

    return AppException(
      message: message,
      type: AppExceptionType.server,
      cause: e,
    );
  }

  static String _firestoreMessageFallback(FirebaseException e) {
    final raw = e.message?.trim() ?? '';
    if (raw.toLowerCase().contains('offline')) {
      return 'Firestore offline ou bloqueado. Desative extensões que bloqueiam '
          'firestore.googleapis.com e recarregue a página.';
    }
    return raw.isNotEmpty ? raw : 'Erro no Firestore (${e.code}).';
  }
}
