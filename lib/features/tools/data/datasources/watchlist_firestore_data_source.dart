import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_firestore_access.dart';
import '../../domain/entities/watchlist_item_entity.dart';

class WatchlistFirestoreDataSource {
  WatchlistFirestoreDataSource({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  CollectionReference<Map<String, dynamic>> _items(String groupId) =>
      FirebaseFirestoreAccess.require(override: _firestoreOverride)
          .collection('groups')
          .doc(groupId)
          .collection('watchlist')
          .doc('shared')
          .collection('items');

  Future<void> removeItem({required String groupId, required int tmdbMovieId}) async {
    await _items(groupId).doc(tmdbMovieId.toString()).delete();
  }

  Future<void> addItem({
    required String groupId,
    required int tmdbMovieId,
    required String title,
    String? posterPath,
  }) async {
    final docId = tmdbMovieId.toString();
    await _items(groupId).doc(docId).set({
      'tmdbMovieId': tmdbMovieId,
      'title': title,
      if (posterPath != null) 'posterPath': posterPath,
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<WatchlistItemEntity>> watchItems({required String groupId}) {
    return _items(groupId).orderBy('addedAt', descending: true).snapshots().map(
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

  /// Copia itens do caminho legado `watchlist/shared/items` para a turma ativa.
  Future<void> migrateLegacySharedItems(String groupId) async {
    final legacy = FirebaseFirestoreAccess.require(override: _firestoreOverride)
        .collection('watchlist')
        .doc('shared')
        .collection('items');
    final snap = await legacy.limit(50).get();
    if (snap.docs.isEmpty) return;

    final batch = FirebaseFirestoreAccess.require(override: _firestoreOverride).batch();
    for (final doc in snap.docs) {
      final data = doc.data();
      final target = _items(groupId).doc(doc.id);
      batch.set(target, data, SetOptions(merge: true));
    }
    await batch.commit();
  }
}
