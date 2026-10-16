import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../social/presentation/providers/social_providers.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/usecases/get_feed_page_use_case.dart';
import '../../domain/usecases/get_review_by_id_use_case.dart';
import '../../domain/usecases/get_movie_group_reviews_use_case.dart';
import '../../domain/usecases/toggle_review_reaction_use_case.dart';
import '../notifiers/feed_notifier.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) => sl<ReviewRepository>());

final getFeedPageUseCaseProvider = Provider(
  (ref) => GetFeedPageUseCase(ref.watch(reviewRepositoryProvider)),
);

final getReviewByIdUseCaseProvider = Provider(
  (ref) => GetReviewByIdUseCase(ref.watch(reviewRepositoryProvider)),
);

final toggleReviewReactionUseCaseProvider = Provider(
  (ref) => ToggleReviewReactionUseCase(ref.watch(reviewRepositoryProvider)),
);

final getMovieGroupReviewsUseCaseProvider = Provider(
  (ref) => GetMovieGroupReviewsUseCase(ref.watch(reviewRepositoryProvider)),
);

final feedNotifierProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final userId = ref.watch(authSessionProvider.select((session) => session.valueOrNull?.id));

  final notifier = FeedNotifier(
    userId: userId,
    isVisible: (review) {
      if (userId == null) return true;
      // Enquanto a lista de quem sigo carrega, não esconde nada.
      final followingIds = ref.read(followingIdsProvider(userId)).valueOrNull;
      return followingIds == null || review.isFromNetworkOf(userId, followingIds);
    },
    getFeedPage: ref.watch(getFeedPageUseCaseProvider),
    getReview: ref.watch(getReviewByIdUseCaseProvider),
    toggleReaction: ref.watch(toggleReviewReactionUseCaseProvider),
  );

  if (userId != null) {
    // Recarrega só quando quem eu sigo muda (não na primeira carga).
    ref.listen(followingIdsProvider(userId), (previous, next) {
      final before = previous?.valueOrNull;
      final after = next.valueOrNull;
      if (before != null && after != null && !setEquals(before, after)) {
        notifier.refresh();
      }
    });
  }

  return notifier;
});

/// Avaliações do filme feitas por você ou por quem você segue.
final movieGroupReviewsProvider = FutureProvider.family<List<ReviewEntity>, int>((ref, movieId) async {
  final reviews = await ref.watch(getMovieGroupReviewsUseCaseProvider).byMovie(movieId);
  return filterToMyNetwork(ref, reviews);
});

/// Mantém só posts do usuário logado e de quem ele segue.
Future<List<ReviewEntity>> filterToMyNetwork(Ref ref, List<ReviewEntity> reviews) async {
  final userId = ref.watch(authSessionProvider.select((s) => s.valueOrNull?.id));
  if (userId == null) return const [];
  final followingIds = await ref.watch(followingIdsProvider(userId).future);
  return reviews.where((review) => review.isFromNetworkOf(userId, followingIds)).toList();
}

final reviewByIdProvider =
    FutureProvider.autoDispose.family<ReviewEntity?, String>((ref, reviewId) {
  return ref.watch(reviewRepositoryProvider).getReviewById(reviewId);
});

/// Posts publicados por um usuário (perfil).
final userReviewsProvider =
    FutureProvider.autoDispose.family<List<ReviewEntity>, String>((ref, authorId) {
  return ref.watch(reviewRepositoryProvider).getReviewsByAuthor(authorId);
});
