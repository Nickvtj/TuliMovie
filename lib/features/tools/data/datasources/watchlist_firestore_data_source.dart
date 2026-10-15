import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_firestore_access.dart';
import '../../domain/entities/watchlist_item_entity.dart';

/// Watchlist pessoal: `users/{uid}/watchlist/{tmdbMovieId}`.
class WatchlistFirestoreDataSource {
  WatchlistFirestoreDataSource({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  static const usersPath = 'users';
  static const watchlistPath = 'watchlist';

  CollectionReference<Map<String, dynamic>> _items(String userId) =>
      FirebaseFirestoreAccess.require(override: _firestoreOverride)
          .collection(usersPath)
          .doc(userId)
          .collection(watchlistPath);

  Future<void> removeItem({required String userId, required int tmdbMovieId}) async {
    await _items(userId).doc(tmdbMovieId.toString()).delete();
  }

  Future<void> addItem({
    required String userId,
    required int tmdbMovieId,
    required String title,
    String? posterPath,
  }) async {
    final docId = tmdbMovieId.toString();
    await _items(userId).doc(docId).set({
      'tmdbMovieId': tmdbMovieId,
      'title': title,
      if (posterPath != null) 'posterPath': posterPath,
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<WatchlistItemEntity>> watchItems({required String userId}) {
    return _items(userId).orderBy('addedAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => WatchlistItemEntity(
                  id: doc.id,
                  tmdbMovieId: (doc.data()['tmdbMovieId'] as num).toInt(),
                  title: doc.data()['title'] as String? ?? '',
                  posterPath: doc.data()['posterPath'] as String?,
                ),
              )
              .toList(),
        );
  }
}
