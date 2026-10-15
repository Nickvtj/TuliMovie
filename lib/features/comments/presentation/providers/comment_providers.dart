import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/usecases/add_comment_use_case.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) => sl<CommentRepository>());

final addCommentUseCaseProvider = Provider((ref) => sl<AddCommentUseCase>());

final commentsProvider =
    StreamProvider.autoDispose.family<List<CommentEntity>, String>((ref, reviewId) {
  return ref.watch(commentRepositoryProvider).watchComments(reviewId);
});
