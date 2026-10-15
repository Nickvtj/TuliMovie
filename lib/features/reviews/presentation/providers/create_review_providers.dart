import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../movies/presentation/providers/movie_providers.dart';
import '../../domain/repositories/review_write_repository.dart';
import '../../domain/usecases/create_review_use_case.dart';
import '../../domain/usecases/list_taggable_friends_use_case.dart';
import '../notifiers/create_review_notifier.dart';

final listTaggableFriendsUseCaseProvider = Provider(
  (ref) => sl<ListTaggableFriendsUseCase>(),
);

final createReviewUseCaseProvider = Provider(
  (ref) => CreateReviewUseCase(sl<ReviewWriteRepository>()),
);

typedef CreateReviewKey = ({int movieId, String userId});

final createReviewNotifierProvider = StateNotifierProvider.autoDispose
    .family<CreateReviewNotifier, CreateReviewState, CreateReviewKey>((ref, key) {
  final movie = ref.watch(movieDetailsProvider(key.movieId)).requireValue;
  final author = ref.watch(authSessionProvider).requireValue!;

  return CreateReviewNotifier(
    tmdbMovieId: key.movieId,
    listFriends: ref.watch(listTaggableFriendsUseCaseProvider),
    createReview: ref.watch(createReviewUseCaseProvider),
    movie: movie,
    author: author,
  );
});
