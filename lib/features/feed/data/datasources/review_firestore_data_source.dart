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

class MergedFeedPageSnapshot {
  MergedFeedPageSnapshot({
    required this.reviews,
    required this.cursorsByGroup,
    required this.hasMore,
  });

  final List<ReviewModel> reviews;
  final Map<String, DocumentSnapshot<Map<String, dynamic>>> cursorsByGroup;
  final bool hasMore;
}

abstract interface class ReviewFirestoreDataSource {
  Future<FeedPageSnapshot> fetchFeedPage({
    required String groupId,
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  });

  Future<MergedFeedPageSnapshot> fetchMergedFeedPage({
    required List<String> groupIds,
    required int limit,
    Map<String, DocumentSnapshot<Map<String, dynamic>>>? cursorsByGroup,
  });

  Future<void> migrateLegacyReviewsToGroup(String groupId);

  Future<void> backfillGroupIdsArray(String groupId);

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
    required String groupId,
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection
        .where('groupIds', arrayContains: groupId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

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
  Future<MergedFeedPageSnapshot> fetchMergedFeedPage({
    required List<String> groupIds,
    required int limit,
    Map<String, DocumentSnapshot<Map<String, dynamic>>>? cursorsByGroup,
  }) async {
    if (groupIds.isEmpty) {
      return MergedFeedPageSnapshot(reviews: const [], cursorsByGroup: const {}, hasMore: false);
    }

    final perGroup = <ReviewModel>[];
    final nextCursors = <String, DocumentSnapshot<Map<String, dynamic>>>{};
    var anyHasMore = false;

    for (final groupId in groupIds) {
      final startAfter = cursorsByGroup?[groupId];
      final page = await fetchFeedPage(
        groupId: groupId,
        limit: limit,
        startAfter: startAfter,
      );
      perGroup.addAll(page.reviews);
      if (page.lastDocument != null) {
        nextCursors[groupId] = page.lastDocument!;
      }
      if (page.hasMore) anyHasMore = true;
    }

    final byId = <String, ReviewModel>{};
    for (final review in perGroup) {
      byId[review.id] = review;
    }

    final sorted = byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final trimmed = sorted.take(limit).toList();

    return MergedFeedPageSnapshot(
      reviews: trimmed,
      cursorsByGroup: nextCursors,
      hasMore: anyHasMore,
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
  Future<void> migrateLegacyReviewsToGroup(String groupId) async {
    final snapshot = await _collection.where('groupId', isNull: true).limit(100).get();
    if (snapshot.docs.isEmpty) return;

    final batch = FirebaseFirestoreAccess.require(override: _firestoreOverride).batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'groupId': groupId,
        'groupIds': [groupId],
      });
    }
    await batch.commit();
  }

  @override
  Future<void> backfillGroupIdsArray(String groupId) async {
    final snapshot = await _collection.where('groupId', isEqualTo: groupId).limit(100).get();
    if (snapshot.docs.isEmpty) return;

    final batch = FirebaseFirestoreAccess.require(override: _firestoreOverride).batch();
    var writes = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final existing = data['groupIds'];
      if (existing is List && existing.isNotEmpty) continue;
      batch.update(doc.reference, {'groupIds': [groupId]});
      writes++;
    }
    if (writes > 0) await batch.commit();
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
