import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_firestore_data_source.dart';
import '../mappers/review_mapper.dart';

class _FirestoreFeedCursor extends FeedCursor {
  _FirestoreFeedCursor(this.document);

  final DocumentSnapshot<Map<String, dynamic>> document;
}

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._dataSource);

  final ReviewFirestoreDataSource _dataSource;

  @override
  Future<FeedPageResult> fetchFeedPage({
    required int limit,
    FeedCursor? cursor,
  }) async {
    try {
      final startAfter = cursor is _FirestoreFeedCursor ? cursor.document : null;
      final page = await _dataSource.fetchFeedPage(
        limit: limit,
        startAfter: startAfter,
      );

      return FeedPageResult(
        reviews: ReviewMapper.toEntityList(page.reviews),
        hasMore: page.hasMore,
        nextCursor:
            page.lastDocument == null ? null : _FirestoreFeedCursor(page.lastDocument!),
      );
    } catch (e) {
      throw AppException(message: 'Erro ao carregar feed.', cause: e);
    }
  }

  @override
  Future<List<ReviewEntity>> getReviewsByMovieId(int tmdbMovieId) async {
    try {
      final models = await _dataSource.fetchByMovieId(tmdbMovieId);
      return ReviewMapper.toEntityList(models);
    } catch (e) {
      throw AppException(message: 'Erro ao carregar avaliações do filme.', cause: e);
    }
  }

  @override
  Future<List<ReviewEntity>> getReviewsByMovieIds(List<int> tmdbMovieIds) async {
    try {
      final models = await _dataSource.fetchByMovieIds(tmdbMovieIds);
      return ReviewMapper.toEntityList(models);
    } catch (e) {
      throw AppException(message: 'Erro ao carregar avaliações da turma.', cause: e);
    }
  }

  @override
  Future<void> toggleReaction({
    required String reviewId,
    required String userId,
    required String reactionKey,
  }) async {
    try {
      await _dataSource.toggleReaction(
        reviewId: reviewId,
        userId: userId,
        reactionKey: reactionKey,
      );
    } catch (e) {
      throw AppException(message: 'Erro ao reagir.', cause: e);
    }
  }
}
