import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_firestore_access.dart';

/// `users/{uid}/following/{targetId}` + espelho `users/{targetId}/followers/{uid}`.
class FollowFirestoreDataSource {
  FollowFirestoreDataSource({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  static const usersPath = 'users';
  static const followingPath = 'following';
  static const followersPath = 'followers';

  /// Teto das listas de seguidores/seguindo nesta fase.
  static const listLimit = 200;

  FirebaseFirestore get _db => FirebaseFirestoreAccess.require(override: _firestoreOverride);

  CollectionReference<Map<String, dynamic>> _following(String userId) =>
      _db.collection(usersPath).doc(userId).collection(followingPath);

  CollectionReference<Map<String, dynamic>> _followers(String userId) =>
      _db.collection(usersPath).doc(userId).collection(followersPath);

  Future<void> follow({required String userId, required String targetId}) async {
    final data = {'createdAt': FieldValue.serverTimestamp()};
    await (_db.batch()
          ..set(_following(userId).doc(targetId), data)
          ..set(_followers(targetId).doc(userId), data))
        .commit();
  }

  Future<void> unfollow({required String userId, required String targetId}) async {
    await (_db.batch()
          ..delete(_following(userId).doc(targetId))
          ..delete(_followers(targetId).doc(userId)))
        .commit();
  }

  Stream<bool> watchIsFollowing({required String userId, required String targetId}) {
    return _following(userId).doc(targetId).snapshots().map((snap) => snap.exists);
  }

  Future<int> countFollowers(String userId) => _count(_followers(userId));

  Future<int> countFollowing(String userId) => _count(_following(userId));

  Future<List<String>> fetchFollowerIds(String userId) => _recentIds(_followers(userId));

  Future<List<String>> fetchFollowingIds(String userId) => _recentIds(_following(userId));

  /// Todos os seguidores, sem teto — usado para montar a audiência de um post.
  Future<List<String>> fetchAllFollowerIds(String userId) async {
    final snapshot = await _followers(userId).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Stream<Set<String>> watchFollowingIds(String userId) {
    return _following(userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Future<int> _count(CollectionReference<Map<String, dynamic>> ref) async {
    final snapshot = await ref.count().get();
    return snapshot.count ?? 0;
  }

  Future<List<String>> _recentIds(CollectionReference<Map<String, dynamic>> ref) async {
    final snapshot = await ref.orderBy('createdAt', descending: true).limit(listLimit).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }
}
