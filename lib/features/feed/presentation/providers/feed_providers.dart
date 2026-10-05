import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/usecases/get_feed_page_use_case.dart';
import '../../domain/usecases/get_movie_group_reviews_use_case.dart';
import '../../domain/usecases/toggle_review_reaction_use_case.dart';
import '../notifiers/feed_notifier.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) => sl<ReviewRepository>());

final getFeedPageUseCaseProvider = Provider(
  (ref) => GetFeedPageUseCase(ref.watch(reviewRepositoryProvider)),
);

final toggleReviewReactionUseCaseProvider = Provider(
  (ref) => ToggleReviewReactionUseCase(ref.watch(reviewRepositoryProvider)),
);

final getMovieGroupReviewsUseCaseProvider = Provider(
  (ref) => GetMovieGroupReviewsUseCase(ref.watch(reviewRepositoryProvider)),
);

final feedNotifierProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(
    getFeedPage: ref.watch(getFeedPageUseCaseProvider),
    toggleReaction: ref.watch(toggleReviewReactionUseCaseProvider),
  );
});

final movieGroupReviewsProvider = FutureProvider.family<List<ReviewEntity>, int>((ref, movieId) async {
  final useCase = ref.watch(getMovieGroupReviewsUseCaseProvider);
  return useCase.byMovie(movieId);
});
