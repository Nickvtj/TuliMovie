import 'package:cloud_firestore/cloud_firestore.dart';

/// Contrato genérico CRUD — evita duplicar código Firestore em cada feature.
abstract interface class IBaseFirestoreService {
  Future<void> create<T>({
    required String collectionPath,
    required String documentId,
    required T data,
    required Map<String, dynamic> Function(T value) toJson,
  });

  Future<T?> read<T>({
    required String collectionPath,
    required String documentId,
    required T Function(Map<String, dynamic> json) fromJson,
  });

  Future<void> update<T>({
    required String collectionPath,
    required String documentId,
    required T data,
    required Map<String, dynamic> Function(T value) toJson,
    bool merge = true,
  });

  Future<void> delete({
    required String collectionPath,
    required String documentId,
  });

  Future<List<T>> query<T>({
    required String collectionPath,
    required T Function(Map<String, dynamic> json) fromJson,
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>> ref)?
        queryBuilder,
    int? limit,
  });

  Stream<T?> watchDocument<T>({
    required String collectionPath,
    required String documentId,
    required T Function(Map<String, dynamic> json) fromJson,
  });

  Stream<List<T>> watchCollection<T>({
    required String collectionPath,
    required T Function(Map<String, dynamic> json) fromJson,
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>> ref)?
        queryBuilder,
    int? limit,
  });
}
