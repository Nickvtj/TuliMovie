import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_firestore_access.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/i_base_firestore_service.dart';
import '../models/user_model.dart';

abstract interface class UserFirestoreDataSource {
  Future<void> upsertUser(UserModel user);

  /// Merge parcial dos campos editáveis (ver [UserModel.profileUpdateJson]).
  Future<void> updateProfile(String userId, Map<String, dynamic> fields);

  Future<UserModel?> getUser(String userId);

  Stream<UserModel?> watchUser(String userId);

  Future<List<UserModel>> fetchAllUsers({String? excludeUserId, int limit = 50});

  Future<List<UserModel>> fetchUsersByIds(List<String> userIds);

  /// Busca por prefixo de `username` e de `displayNameLower` (sem duplicados).
  Future<List<UserModel>> searchUsers(String prefix, {int limit = 20});

  Future<bool> isUsernameAvailable(String username);

  /// Dono do @ ou `null` se não existir.
  Future<String?> findUserIdByUsername(String username);

  /// Reserva `usernames/{username}` e grava no perfil, atomicamente.
  Future<void> claimUsername({required String userId, required String username});
}

class UserFirestoreDataSourceImpl implements UserFirestoreDataSource {
  UserFirestoreDataSourceImpl(this._firestore, {FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  static const collectionPath = 'users';
  static const usernamesCollectionPath = 'usernames';

  /// Limite do Firestore para `whereIn`.
  static const _whereInChunkSize = 30;

  final IBaseFirestoreService _firestore;
  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _db => FirebaseFirestoreAccess.require(override: _firestoreOverride);

  @override
  Future<void> upsertUser(UserModel user) async {
    await _firestore.update<UserModel>(
      collectionPath: collectionPath,
      documentId: user.id,
      data: user,
      toJson: (value) => value.toJson(),
      merge: true,
    );
  }

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> fields) async {
    await _firestore.update<Map<String, dynamic>>(
      collectionPath: collectionPath,
      documentId: userId,
      data: fields,
      toJson: (value) => value,
      merge: true,
    );
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    return _firestore.read<UserModel>(
      collectionPath: collectionPath,
      documentId: userId,
      fromJson: UserModel.fromJson,
    );
  }

  @override
  Stream<UserModel?> watchUser(String userId) {
    return _firestore.watchDocument<UserModel>(
      collectionPath: collectionPath,
      documentId: userId,
      fromJson: UserModel.fromJson,
    );
  }

  @override
  Future<List<UserModel>> fetchAllUsers({String? excludeUserId, int limit = 50}) async {
    final users = await _firestore.query<UserModel>(
      collectionPath: collectionPath,
      fromJson: UserModel.fromJson,
      limit: limit,
    );

    if (excludeUserId == null) return users;
    return users.where((user) => user.id != excludeUserId).toList();
  }

  @override
  Future<List<UserModel>> fetchUsersByIds(List<String> userIds) async {
    final users = <UserModel>[];
    for (var i = 0; i < userIds.length; i += _whereInChunkSize) {
      final chunk = userIds.skip(i).take(_whereInChunkSize).toList();
      users.addAll(
        await _firestore.query<UserModel>(
          collectionPath: collectionPath,
          fromJson: UserModel.fromJson,
          queryBuilder: (ref) => ref.where(FieldPath.documentId, whereIn: chunk),
        ),
      );
    }
    return users;
  }

  @override
  Future<List<UserModel>> searchUsers(String prefix, {int limit = 20}) async {
    final results = await Future.wait([
      _searchByPrefix(field: 'username', prefix: prefix, limit: limit),
      _searchByPrefix(field: 'displayNameLower', prefix: prefix, limit: limit),
    ]);

    final byId = <String, UserModel>{};
    for (final user in results.expand((users) => users)) {
      byId[user.id] = user;
    }
    return byId.values.toList();
  }

  Future<List<UserModel>> _searchByPrefix({
    required String field,
    required String prefix,
    required int limit,
  }) {
    return _firestore.query<UserModel>(
      collectionPath: collectionPath,
      fromJson: UserModel.fromJson,
      queryBuilder: (ref) => ref
          .where(field, isGreaterThanOrEqualTo: prefix)
          .where(field, isLessThan: '$prefix')
          .orderBy(field),
      limit: limit,
    );
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    return await findUserIdByUsername(username) == null;
  }

  @override
  Future<String?> findUserIdByUsername(String username) {
    return _firestore.read<String?>(
      collectionPath: usernamesCollectionPath,
      documentId: username,
      fromJson: (json) => json['uid'] as String?,
    );
  }

  @override
  Future<void> claimUsername({required String userId, required String username}) async {
    final usernameRef = _db.collection(usernamesCollectionPath).doc(username);
    final userRef = _db.collection(collectionPath).doc(userId);

    try {
      await _db.runTransaction((transaction) async {
        final existing = await transaction.get(usernameRef);
        final ownerId = existing.data()?['uid'] as String?;
        if (existing.exists && ownerId != userId) {
          throw const AppException(
            message: 'Esse @ já está em uso. Escolha outro.',
            type: AppExceptionType.validation,
          );
        }

        if (!existing.exists) {
          transaction.set(usernameRef, {
            'uid': userId,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        transaction.set(
          userRef,
          {
            'username': username,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw AppException(
        message: 'Não foi possível reservar seu @.',
        type: AppExceptionType.server,
        cause: e,
      );
    }
  }
}
