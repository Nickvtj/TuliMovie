import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_firestore_access.dart';
import '../models/review_model.dart';

class FeedPageSnapshot {
  FeedPageSnapshot({
    required this.reviews,
    required this.lastDocument,
    required this.hasMore,
  });

  final List<ReviewModel> reviews;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;
}

abstract interface class ReviewFirestoreDataSource {
  Future<FeedPageSnapshot> fetchFeedPage({
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  });

  Future<List<ReviewModel>> fetchByMovieId(int tmdbMovieId, {int limit = 20});

  Future<List<ReviewModel>> fetchByMovieIds(List<int> tmdbMovieIds, {int limit = 30});

  Future<void> toggleReaction({
    required String reviewId,
    required String userId,
    required String reactionKey,
  });

  Future<ReviewModel> createReview(ReviewModel review);

  Future<List<ReviewModel>> fetchRecentReviews({int limit = 250});
}

class ReviewFirestoreDataSourceImpl implements ReviewFirestoreDataSource {
  ReviewFirestoreDataSourceImpl({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  static const collectionPath = 'reviews';

  final FirebaseFirestore? _firestoreOverride;

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestoreAccess.require(override: _firestoreOverride).collection(collectionPath);

  @override
  Future<FeedPageSnapshot> fetchFeedPage({
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query =
        _collection.orderBy('createdAt', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final reviews = snapshot.docs
        .map((doc) => ReviewModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    final lastDoc = snapshot.docs.isEmpty ? null : snapshot.docs.last;

    return FeedPageSnapshot(
      reviews: reviews,
      lastDocument: lastDoc,
      hasMore: snapshot.docs.length >= limit,
    );
  }

  @override
  Future<List<ReviewModel>> fetchByMovieId(int tmdbMovieId, {int limit = 20}) async {
    final snapshot = await _collection
        .where('tmdbMovieId', isEqualTo: tmdbMovieId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<List<ReviewModel>> fetchByMovieIds(
    List<int> tmdbMovieIds, {
    int limit = 30,
  }) async {
    if (tmdbMovieIds.isEmpty) return [];

    final ids = tmdbMovieIds.take(10).toList();
    final snapshot = await _collection
        .where('tmdbMovieId', whereIn: ids)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<List<ReviewModel>> fetchRecentReviews({int limit = 250}) async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<ReviewModel> createReview(ReviewModel review) async {
    final docRef = review.id.isEmpty ? _collection.doc() : _collection.doc(review.id);
    final payload = review.copyWithId(docRef.id);

    await docRef.set(payload.toJson());
    return payload;
  }

  @override
  Future<void> toggleReaction({
    required String reviewId,
    required String userId,
    required String reactionKey,
  }) async {
    final docRef = _collection.doc(reviewId);

    await FirebaseFirestoreAccess.require(override: _firestoreOverride).runTransaction((transaction) async {
      final snap = await transaction.get(docRef);
      if (!snap.exists) return;

      final data = snap.data() ?? {};
      final reactionsRaw = Map<String, dynamic>.from(data['reactions'] as Map? ?? {});
      final current = (reactionsRaw[reactionKey] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();

      if (current.contains(userId)) {
        current.remove(userId);
      } else {
        current.add(userId);
      }

      reactionsRaw[reactionKey] = current;
      transaction.update(docRef, {'reactions': reactionsRaw});
    });
  }
}
