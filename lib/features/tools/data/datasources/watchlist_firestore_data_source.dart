import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_firestore_access.dart';
import '../../domain/entities/watchlist_item_entity.dart';

class WatchlistFirestoreDataSource {
  WatchlistFirestoreDataSource({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  CollectionReference<Map<String, dynamic>> get _items =>
      FirebaseFirestoreAccess.require(override: _firestoreOverride)
          .collection('watchlist')
          .doc('shared')
          .collection('items');

  Future<void> removeItem({required int tmdbMovieId}) async {
    await _items.doc(tmdbMovieId.toString()).delete();
  }

  Future<void> addItem({
    required int tmdbMovieId,
    required String title,
    String? posterPath,
  }) async {
    final docId = tmdbMovieId.toString();
    await _items.doc(docId).set({
      'tmdbMovieId': tmdbMovieId,
      'title': title,
      if (posterPath != null) 'posterPath': posterPath,
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<WatchlistItemEntity>> watchItems() {
    return _items.orderBy('addedAt', descending: true).snapshots().map(
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
