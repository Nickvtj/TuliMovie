import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/tmdb_image_url.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../../../feed/presentation/widgets/review_card_widget.dart';
import '../providers/movie_providers.dart';
import 'movie_details_page.dart';

class ActorDetailsPage extends ConsumerWidget {
  const ActorDetailsPage({super.key, required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personAsync = ref.watch(personDetailsProvider(personId));
    final reviewsAsync = ref.watch(actorGroupReviewsProvider(personId));
    final user = ref.watch(authSessionProvider).valueOrNull;

    return personAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Erro ao carregar ficha: $e')),
      ),
      data: (person) {
        final photo = TmdbImageUrl.profile(person.profilePath);

        return Scaffold(
          appBar: AppBar(title: Text(person.name)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
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
                        if (person.knownForDepartment != null)
                          Text(
                            person.knownForDepartment!,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.gold,
                                ),
                          ),
                        if (person.placeOfBirth != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            person.placeOfBirth!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (person.biography != null && person.biography!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Biografia', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  person.biography!,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Assistidos pela Turma',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              reviewsAsync.when(
                loading: () => const TuliFeedSkeleton(itemCount: 2),
                error: (_, __) => const Text('Erro ao carregar avaliações da turma.'),
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return Text(
                      'Nenhum filme com ${person.name} foi avaliado pelo grupo ainda.',
                      style: Theme.of(context).textTheme.bodyMedium,
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
                                  await ref.read(feedNotifierProvider.notifier).toggleReaction(
                                        reviewId: review.id,
                                        userId: user.id,
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
            ],
          ),
        );
      },
    );
  }
}
