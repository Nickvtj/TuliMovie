import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/data/datasources/user_firestore_data_source.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../feed/data/datasources/review_firestore_data_source.dart';
import '../../../notifications/data/datasources/notification_firestore_data_source.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_firestore_data_source.dart';
import '../models/comment_model.dart';

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl({
    required CommentFirestoreDataSource comments,
    required ReviewFirestoreDataSource reviews,
    required UserFirestoreDataSource users,
    required NotificationFirestoreDataSource notifications,
  })  : _comments = comments,
        _reviews = reviews,
        _users = users,
        _notifications = notifications;

  final CommentFirestoreDataSource _comments;
  final ReviewFirestoreDataSource _reviews;
  final UserFirestoreDataSource _users;
  final NotificationFirestoreDataSource _notifications;

  /// Trecho do comentário guardado na notificação.
  static const _snippetLength = 80;

  @override
  Stream<List<CommentEntity>> watchComments(String reviewId) {
    return _comments
        .watchComments(reviewId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> addComment({
    required String reviewId,
    required UserEntity author,
    required String text,
    required Set<String> mentionedUsernames,
  }) async {
    try {
      final mentions = await _resolveMentions(mentionedUsernames);
      await _comments.addComment(
        CommentModel(
          reviewId: reviewId,
          authorId: author.id,
          authorName: author.displayName,
          authorPhotoUrl: author.photoUrl,
          text: text,
          mentions: mentions,
        ),
      );
      await _notify(reviewId: reviewId, author: author, text: text, mentions: mentions);
    } on FirebaseException catch (e) {
      throw AppException(
        message: 'Não foi possível comentar.',
        type: AppExceptionType.server,
        cause: e,
      );
    }
  }

  /// Ignora @ que não existem.
  Future<Map<String, String>> _resolveMentions(Set<String> usernames) async {
    final entries = await Future.wait(
      usernames.map((username) async {
        final userId = await _users.findUserIdByUsername(username);
        return userId == null ? null : MapEntry(username, userId);
      }),
    );
    return Map.fromEntries(entries.whereType<MapEntry<String, String>>());
  }

  /// Melhor esforço: o comentário já valeu mesmo se o aviso falhar.
  /// Mencionado recebe "mention"; autor do post (se não mencionado) recebe "comment".
  Future<void> _notify({
    required String reviewId,
    required UserEntity author,
    required String text,
    required Map<String, String> mentions,
  }) async {
    try {
      final review = await _reviews.fetchById(reviewId);
      final recipients = <String, NotificationType>{
        if (review != null && review.authorId.isNotEmpty)
          review.authorId: NotificationType.comment,
        for (final userId in mentions.values) userId: NotificationType.mention,
      }..remove(author.id);

      final snippet =
          text.length > _snippetLength ? '${text.substring(0, _snippetLength)}…' : text;

      await _notifications.createMany([
        for (final recipient in recipients.entries)
          NotificationModel(
            recipientId: recipient.key,
            type: recipient.value,
            actorId: author.id,
            actorName: author.displayName,
            actorPhotoUrl: author.photoUrl,
            reviewId: reviewId,
            movieTitle: review?.movieTitle,
            text: snippet,
          ),
      ]);
    } catch (_) {}
  }
}
