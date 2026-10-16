import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../../../feed/presentation/widgets/review_card_widget.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';
import '../../../profile/presentation/widgets/favorite_actors_row.dart';
import '../../../profile/presentation/widgets/favorite_movies_row.dart';
import '../providers/social_providers.dart';
import '../widgets/follow_button.dart';
import '../widgets/follow_stats_row.dart';
import '../widgets/mutual_badge.dart';

/// Perfil público de qualquer usuário.
class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider(userId));
    final status = ref.watch(followStatusProvider(userId));
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: profile.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: TuliFeedSkeleton(itemCount: 2),
          ),
          error: (e, _) => const TuliEmptyState(
            message: 'Não foi possível carregar o perfil.',
            icon: Icons.error_outline_rounded,
          ),
          data: (user) {
            if (user == null) {
              return const TuliEmptyState(
                message: 'Perfil não encontrado.',
                icon: Icons.person_off_outlined,
              );
            }

            return ListView(
              children: [
                TuliScreenHeader(
                  mode: TuliScreenHeaderMode.stacked,
                  title: user.hasUsername ? '@${user.username}' : user.displayName,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      TuliRingAvatar(
                        displayName: user.displayName,
                        imageUrl: user.photoUrl,
                        size: 80,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(user.displayName, style: textTheme.headlineSmall),
                      if (user.hasUsername)
                        Text(
                          '@${user.username}',
                          style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                        ),
                      if (status != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        MutualBadge(status: status),
                      ],
                      if (user.hasBio) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          user.bio!,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      FollowStatsRow(userId: userId),
                      const SizedBox(height: AppSpacing.lg),
                      FollowButton(targetId: userId),
                      if (user.favoriteMovies.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        const TuliSectionTitle(title: 'Top 4 filmes'),
                        const SizedBox(height: AppSpacing.sm),
                        FavoriteMoviesRow(movies: user.favoriteMovies),
                      ],
                      if (user.favoriteActors.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        const TuliSectionTitle(title: 'Top 4 atores'),
                        const SizedBox(height: AppSpacing.sm),
                        FavoriteActorsRow(actors: user.favoriteActors),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.section,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text('Avaliações', style: textTheme.titleMedium),
                ),
                _UserReviewsList(userId: userId),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UserReviewsList extends ConsumerWidget {
  const _UserReviewsList({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userReviewsProvider(userId)).when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: TuliFeedSkeleton(itemCount: 2),
          ),
          error: (e, _) => const TuliEmptyState(
            message: 'Não foi possível carregar as avaliações.',
            icon: Icons.error_outline_rounded,
          ),
          data: (reviews) {
            if (reviews.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: TuliEmptyState(
                  message: 'Nenhuma avaliação ainda.',
                  icon: Icons.movie_filter_outlined,
                ),
              );
            }
            return Column(
              children: [
                for (final review in reviews)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: ReviewCardWidget(
                      review: review,
                      compact: true,
                      onOpenMovie: (_) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => MovieDetailsPage(movieId: review.tmdbMovieId),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        );
  }
}
