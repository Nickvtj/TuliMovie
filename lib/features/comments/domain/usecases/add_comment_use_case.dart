import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/comment_repository.dart';
import '../utils/mention_parser.dart';

class AddCommentUseCase {
  AddCommentUseCase(this._repository);

  static const maxLength = 500;

  final CommentRepository _repository;

  Future<void> call({
    required String reviewId,
    required UserEntity author,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const AppException(
        message: 'Escreva algo antes de enviar.',
        type: AppExceptionType.validation,
      );
    }
    if (trimmed.length > maxLength) {
      throw const AppException(
        message: 'Comentário com no máximo $maxLength caracteres.',
        type: AppExceptionType.validation,
      );
    }

    await _repository.addComment(
      reviewId: reviewId,
      author: author,
      text: trimmed,
      mentionedUsernames: MentionParser.usernames(trimmed),
    );
  }
}
