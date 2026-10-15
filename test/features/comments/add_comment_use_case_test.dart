import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/core/errors/app_exception.dart';
import 'package:tulimovie/features/auth/domain/entities/user_entity.dart';
import 'package:tulimovie/features/comments/domain/entities/comment_entity.dart';
import 'package:tulimovie/features/comments/domain/repositories/comment_repository.dart';
import 'package:tulimovie/features/comments/domain/usecases/add_comment_use_case.dart';

class _FakeCommentRepository implements CommentRepository {
  String? text;
  Set<String>? mentions;

  @override
  Stream<List<CommentEntity>> watchComments(String reviewId) => const Stream.empty();

  @override
  Future<void> addComment({
    required String reviewId,
    required UserEntity author,
    required String text,
    required Set<String> mentionedUsernames,
  }) async {
    this.text = text;
    mentions = mentionedUsernames;
  }
}

void main() {
  const author = UserEntity(id: 'u1', email: '', displayName: 'Ana');

  test('envia texto aparado com as menções encontradas', () async {
    final repository = _FakeCommentRepository();
    await AddCommentUseCase(repository)(
      reviewId: 'r1',
      author: author,
      text: '  filmaço @bia  ',
    );

    expect(repository.text, 'filmaço @bia');
    expect(repository.mentions, {'bia'});
  });

  test('rejeita comentário vazio ou longo demais', () async {
    final useCase = AddCommentUseCase(_FakeCommentRepository());

    expect(
      () => useCase(reviewId: 'r1', author: author, text: '   '),
      throwsA(isA<AppException>()),
    );
    expect(
      () => useCase(
        reviewId: 'r1',
        author: author,
        text: 'a' * (AddCommentUseCase.maxLength + 1),
      ),
      throwsA(isA<AppException>()),
    );
  });
}
