import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_firestore_access.dart';
import '../models/comment_model.dart';

/// `reviews/{reviewId}/comments/{commentId}` + contador `commentCount` na review.
class CommentFirestoreDataSource {
  CommentFirestoreDataSource({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  static const reviewsPath = 'reviews';
  static const commentsPath = 'comments';
  static const listLimit = 100;

  FirebaseFirestore get _db => FirebaseFirestoreAccess.require(override: _firestoreOverride);

  DocumentReference<Map<String, dynamic>> _review(String reviewId) =>
      _db.collection(reviewsPath).doc(reviewId);

  Stream<List<CommentModel>> watchComments(String reviewId) {
    return _review(reviewId)
        .collection(commentsPath)
        .orderBy('createdAt')
        .limitToLast(listLimit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromJson(reviewId, {...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  Future<void> addComment(CommentModel comment) async {
    final review = _review(comment.reviewId);
    await (_db.batch()
          ..set(review.collection(commentsPath).doc(), comment.toJson())
          ..update(review, {'commentCount': FieldValue.increment(1)}))
        .commit();
  }
}
