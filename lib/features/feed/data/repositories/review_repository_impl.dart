import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_firestore_data_source.dart';
import '../mappers/review_mapper.dart';
import '../models/review_model.dart';

class _FirestoreFeedCursor extends FeedCursor {
  _FirestoreFeedCursor(this.document);

  final DocumentSnapshot<Map<String, dynamic>> document;
}

class _MergedFirestoreFeedCursor extends FeedCursor {
  _MergedFirestoreFeedCursor(this.cursorsByGroup);

  final Map<String, DocumentSnapshot<Map<String, dynamic>>> cursorsByGroup;
}

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._dataSource);

  final ReviewFirestoreDataSource _dataSource;

  @override
  Future<FeedPageResult> fetchFeedPage({
    required String groupId,
    required int limit,
    FeedCursor? cursor,
  }) async {
    try {
      final startAfter = cursor is _FirestoreFeedCursor ? cursor.document : null;
      final page = await _dataSource.fetchFeedPage(
        groupId: groupId,
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
  Future<FeedPageResult> fetchMergedFeedPage({
    required List<String> groupIds,
    required int limit,
    FeedCursor? cursor,
  }) async {
    try {
      final cursors = cursor is _MergedFirestoreFeedCursor ? cursor.cursorsByGroup : null;
      final page = await _dataSource.fetchMergedFeedPage(
        groupIds: groupIds,
        limit: limit,
        cursorsByGroup: cursors,
      );

      return FeedPageResult(
        reviews: ReviewMapper.toEntityList(page.reviews),
        hasMore: page.hasMore,
        nextCursor: page.cursorsByGroup.isEmpty
            ? null
            : _MergedFirestoreFeedCursor(page.cursorsByGroup),
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
      if (tmdbMovieIds.isEmpty) return const [];

      final allModels = <ReviewModel>[];
      for (var i = 0; i < tmdbMovieIds.length; i += 10) {
        final end = i + 10 > tmdbMovieIds.length ? tmdbMovieIds.length : i + 10;
        final chunk = tmdbMovieIds.sublist(i, end);
        allModels.addAll(await _dataSource.fetchByMovieIds(chunk));
      }
      return ReviewMapper.toEntityList(allModels);
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

  @override
  Future<Set<int>> watchedMovieIdsForUsers(Set<String> userIds) async {
    if (userIds.isEmpty) return {};
    try {
      final reviews = await _dataSource.fetchRecentReviews();
      final watched = <int>{};

      for (final review in reviews) {
        final involved = review.participants.any((p) => userIds.contains(p.userId));
        if (involved) watched.add(review.tmdbMovieId);
      }
      return watched;
    } catch (e) {
      throw AppException(message: 'Erro ao calcular histórico assistido.', cause: e);
    }
  }
}
