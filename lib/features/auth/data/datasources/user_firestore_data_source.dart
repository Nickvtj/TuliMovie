import '../../../../core/services/i_base_firestore_service.dart';
import '../models/user_model.dart';

abstract interface class UserFirestoreDataSource {
  Future<void> upsertUser(UserModel user);

  Future<UserModel?> getUser(String userId);

  Future<List<UserModel>> fetchAllUsers({String? excludeUserId, int limit = 50});
}

class UserFirestoreDataSourceImpl implements UserFirestoreDataSource {
  UserFirestoreDataSourceImpl(this._firestore);

  static const collectionPath = 'users';

  final IBaseFirestoreService _firestore;

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
  Future<UserModel?> getUser(String userId) async {
    return _firestore.read<UserModel>(
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
}
