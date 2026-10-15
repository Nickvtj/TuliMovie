import '../../../auth/domain/entities/user_entity.dart';
import '../entities/comment_entity.dart';

abstract interface class CommentRepository {
  Stream<List<CommentEntity>> watchComments(String reviewId);

  /// Publica o comentário e avisa o autor do post e quem foi mencionado.
  Future<void> addComment({
    required String reviewId,
    required UserEntity author,
    required String text,
    required Set<String> mentionedUsernames,
  });
}
