import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/watchlist_item_entity.dart';

class WatchlistFirestoreDataSource {
  WatchlistFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _items =>
      _firestore.collection('watchlist').doc('shared').collection('items');

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
