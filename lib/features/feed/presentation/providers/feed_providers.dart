import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../groups/presentation/providers/group_providers.dart';
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

/// Aba do feed: `null` = Todas as turmas; caso contrário, id da turma.
final feedTabGroupIdProvider = StateProvider<FeedTabGroupId>((ref) => null);

final groupNameMapProvider = Provider<Map<String, String>>((ref) {
  final groups = ref.watch(userGroupsProvider).valueOrNull ?? [];
  return {for (final g in groups) g.id: g.name};
});

final feedNotifierProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  ref.watch(groupBootstrapProvider);

  final notifier = FeedNotifier(
    resolveFeedTab: () => ref.read(feedTabGroupIdProvider),
    resolveMemberGroupIds: () {
      final groups = ref.read(userGroupsProvider).valueOrNull ?? [];
      return groups.map((g) => g.id).toList();
    },
    getFeedPage: ref.watch(getFeedPageUseCaseProvider),
    toggleReaction: ref.watch(toggleReviewReactionUseCaseProvider),
  );

  ref.listen<FeedTabGroupId>(feedTabGroupIdProvider, (previous, next) {
    if (next != previous) {
      notifier.refresh();
    }
  });

  ref.listen(userGroupsProvider, (previous, next) {
    final prevIds = previous?.valueOrNull?.map((g) => g.id).toList() ?? [];
    final nextIds = next.valueOrNull?.map((g) => g.id).toList() ?? [];
    if (prevIds.join() != nextIds.join()) {
      notifier.refresh();
    }
  });

  return notifier;
});

final movieGroupReviewsProvider = FutureProvider.family<List<ReviewEntity>, int>((ref, movieId) async {
  final useCase = ref.watch(getMovieGroupReviewsUseCaseProvider);
  return useCase.byMovie(movieId);
});
