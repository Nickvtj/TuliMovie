import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/tmdb_image_url.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../../../feed/presentation/widgets/review_card_widget.dart';
import '../providers/movie_providers.dart';
import '../widgets/cast_carousel.dart';
import '../widgets/streaming_provider_chip.dart';
import 'actor_details_page.dart';

class MovieDetailsPage extends ConsumerWidget {
  const MovieDetailsPage({super.key, required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(movieDetailsProvider(movieId));
    final reviewsAsync = ref.watch(movieGroupReviewsProvider(movieId));
    final user = ref.watch(authSessionProvider).valueOrNull;

    return detailsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: TuliPosterSkeleton(width: 160)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Erro ao carregar filme: $e')),
      ),
      data: (details) {
        final movie = details.movie;
        final backdrop = TmdbImageUrl.poster(movie.backdropPath ?? movie.posterPath, size: 'w780');

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (backdrop != null)
                        CachedNetworkImage(
                          imageUrl: backdrop,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              const ColoredBox(color: AppColors.backgroundDeep),
                        )
                      else
                        const ColoredBox(color: AppColors.backgroundDeep),
                      const DecoratedBox(
                        decoration: BoxDecoration(gradient: AppGradients.cardOverlay),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TuliPosterImage(posterPath: movie.posterPath, width: 110),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (details.genres.isNotEmpty)
                                  Text(
                                    details.genres.join(' · '),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                const SizedBox(height: 8),
                                TuliRatingStars(
                                  value: movie.voteAverage / 2,
                                  readOnly: true,
                                  maxStars: 5,
                                  starSize: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'TMDB ${movie.voteAverage.toStringAsFixed(1)}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                if (details.runtimeMinutes != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '${details.runtimeMinutes} min',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (movie.overview != null && movie.overview!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('Sinopse', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(movie.overview!, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                      if (details.streamingProviders.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text('Onde assistir', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: details.streamingProviders
                              .map((p) => StreamingProviderChip(provider: p))
                              .toList(),
                        ),
                      ],
                      if (details.directors.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text('Direção', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: details.directors.map((director) {
                            return ActionChip(
                              label: Text(director.name),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ActorDetailsPage(personId: director.id),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Text('Elenco', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      CastCarousel(
                        cast: details.cast,
                        onTapMember: (member) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ActorDetailsPage(personId: member.id),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Avaliações do Nosso Grupo',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      reviewsAsync.when(
                        loading: () => const TuliFeedSkeleton(itemCount: 2),
                        error: (_, __) => const Text('Não foi possível carregar as avaliações.'),
                        data: (reviews) {
                          if (reviews.isEmpty) {
                            return Text(
                              'A turma ainda não avaliou este filme.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            );
                          }
                          return Column(
                            children: reviews
                                .map(
                                  (review) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: ReviewCardWidget(
                                      review: review,
                                      compact: true,
                                      onReact: user == null
                                          ? null
                                          : (key) async {
                                              await ref
                                                  .read(feedNotifierProvider.notifier)
                                                  .toggleReaction(
                                                    reviewId: review.id,
                                                    userId: user.id,
                                                    reactionKey: key,
                                                  );
                                              ref.invalidate(movieGroupReviewsProvider(movieId));
                                            },
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
