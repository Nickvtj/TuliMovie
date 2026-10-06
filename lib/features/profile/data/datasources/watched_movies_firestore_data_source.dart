import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_firestore_access.dart';
import '../../domain/entities/watched_movie_entity.dart';

class WatchedMoviesFirestoreDataSource {
  WatchedMoviesFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return FirebaseFirestoreAccess.require(override: _firestoreOverride)
        .collection('users')
        .doc(userId)
        .collection('watched');
  }

  Future<Set<int>> fetchWatchedIds(String userId) async {
    final snapshot = await _collection(userId).get();
    return snapshot.docs
        .map((doc) => int.tryParse(doc.id) ?? (doc.data()['tmdbMovieId'] as num?)?.toInt())
        .whereType<int>()
        .toSet();
  }

  Future<void> upsertWatched({
    required String userId,
    required int tmdbMovieId,
    required String title,
    String? posterPath,
    WatchedMovieSource source = WatchedMovieSource.discover,
  }) async {
    await _collection(userId).doc(tmdbMovieId.toString()).set({
      'tmdbMovieId': tmdbMovieId,
      'title': title,
      if (posterPath != null) 'posterPath': posterPath,
      'watchedAt': FieldValue.serverTimestamp(),
      'source': source.name,
    }, SetOptions(merge: true));
  }

  Future<List<WatchedMovieEntity>> fetchWatched(String userId, {int limit = 200}) async {
    final snapshot = await _collection(userId)
        .orderBy('watchedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return WatchedMovieEntity(
        tmdbMovieId: (data['tmdbMovieId'] as num?)?.toInt() ?? int.parse(doc.id),
        title: data['title'] as String? ?? '',
        posterPath: data['posterPath'] as String?,
        watchedAt: (data['watchedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        source: WatchedMovieSource.values.byName(
          data['source'] as String? ?? WatchedMovieSource.discover.name,
        ),
      );
    }).toList();
  }
}
