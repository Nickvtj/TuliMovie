import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/tmdb_image_url.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../discover/presentation/widgets/discover_carousel_widget.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../../../feed/presentation/widgets/review_card_widget.dart';
import '../../domain/entities/person_entity.dart';
import '../providers/movie_providers.dart';
import 'movie_details_page.dart';

class ActorDetailsPage extends ConsumerWidget {
  const ActorDetailsPage({super.key, required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personAsync = ref.watch(personDetailsProvider(personId));
    final filmographyAsync = ref.watch(personFilmographyProvider(personId));
    final reviewsAsync = ref.watch(actorGroupReviewsProvider(personId));
    final user = ref.watch(authSessionProvider).valueOrNull;

    return personAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Erro ao carregar ficha: $e')),
      ),
      data: (person) {
        return Scaffold(
          appBar: AppBar(title: Text(person.name)),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _PersonHeader(person: person),
              ),
              filmographyAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: TuliFeedSkeleton(itemCount: 2),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TuliEmptyState(
                    message: 'Não foi possível carregar a filmografia.\n$e',
                  ),
                ),
                data: (filmography) {
                  final movies = filmography.allMovies;
                  if (movies.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TuliEmptyState(message: 'Nenhum filme encontrado para este artista.'),
                    );
                  }

                  final groupWatchedIds = reviewsAsync.maybeWhen(
                    data: (reviews) => reviews.map((r) => r.tmdbMovieId).toSet(),
                    orElse: () => <int>{},
                  );

                  return DiscoverCarouselWidget(
                    title: 'Filmografia',
                    subtitle: '${movies.length} títulos no TMDB',
                    movies: movies.take(40).toList(),
                    groupWatchedMovieIds: groupWatchedIds,
                    onMarkWatched: null,
                    onAddWatchlist: null,
                  );
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Assistidos pela turma',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: reviewsAsync.when(
                  loading: () => const TuliFeedSkeleton(itemCount: 2),
                  error: (_, __) => const TuliEmptyState(
                    message:
                        'Não foi possível carregar as avaliações da turma.\nTente novamente em instantes.',
                  ),
                  data: (reviews) {
                    if (reviews.isEmpty) {
                      return TuliEmptyState(
                        message: 'A turma ainda não avaliou outros filmes com ${person.name}.',
                      );
                    }

                    return Column(
                      children: reviews.map((review) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
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
                            onReact: user == null
                                ? null
                                : (key) async {
                                    final uid = user!.id;
                                    await ref.read(feedNotifierProvider.notifier).toggleReaction(
                                          reviewId: review.id,
                                          userId: uid,
                                          reactionKey: key,
                                        );
                                    ref.invalidate(actorGroupReviewsProvider(personId));
                                  },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PersonHeader extends StatelessWidget {
  const _PersonHeader({required this.person});

  final PersonEntity person;

  @override
  Widget build(BuildContext context) {
    final photo = TmdbImageUrl.profile(person.profilePath);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: AppShape.borderRadiusMd,
          child: photo == null
              ? Container(
                  width: 110,
                  height: 110,
                  color: AppColors.surfaceMuted,
                  child: const Icon(Icons.person, size: 48),
                )
              : CachedNetworkImage(
                  imageUrl: photo,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(person.name, style: Theme.of(context).textTheme.titleLarge),
              if (person.knownForDepartment != null)
                Text(
                  person.knownForDepartment!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.gold),
                ),
              if (person.placeOfBirth != null) ...[
                const SizedBox(height: 6),
                Text(person.placeOfBirth!, style: Theme.of(context).textTheme.bodySmall),
              ],
              if (person.biography != null && person.biography!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  person.biography!,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
