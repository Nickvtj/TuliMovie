import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../groups/presentation/providers/group_providers.dart';
import '../../../movies/presentation/providers/movie_providers.dart';
import '../../domain/repositories/group_members_repository.dart';
import '../../domain/repositories/review_write_repository.dart';
import '../../domain/usecases/create_review_use_case.dart';
import '../../domain/usecases/list_group_members_use_case.dart';
import '../notifiers/create_review_notifier.dart';

final listGroupMembersUseCaseProvider = Provider(
  (ref) => ListGroupMembersUseCase(sl<GroupMembersRepository>()),
);

final createReviewUseCaseProvider = Provider(
  (ref) => CreateReviewUseCase(sl<ReviewWriteRepository>()),
);

typedef CreateReviewKey = ({int movieId, String userId});

final createReviewNotifierProvider = StateNotifierProvider.autoDispose
    .family<CreateReviewNotifier, CreateReviewState, CreateReviewKey>((ref, key) {
  final movie = ref.watch(movieDetailsProvider(key.movieId)).requireValue;
  final author = ref.watch(authSessionProvider).requireValue!;

  final groups = ref.watch(userGroupsProvider).valueOrNull ?? [];
  if (groups.isEmpty) {
    throw StateError('Você precisa estar em ao menos uma turma.');
  }

  return CreateReviewNotifier(
    tmdbMovieId: key.movieId,
    listMembers: ref.watch(listGroupMembersUseCaseProvider),
    createReview: ref.watch(createReviewUseCaseProvider),
    movie: movie,
    author: author,
    userGroups: groups,
  );
});
