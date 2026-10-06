import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../feed/domain/entities/review_entity.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../../domain/entities/movie_details_entity.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/person_entity.dart';
import '../../domain/repositories/movie_repository.dart';
import '../notifiers/movie_search_notifier.dart';

final movieRepositoryProvider = Provider<MovieRepository>((ref) => sl<MovieRepository>());

final movieSearchNotifierProvider =
    StateNotifierProvider<MovieSearchNotifier, MovieSearchState>((ref) {
  return MovieSearchNotifier(ref.watch(movieRepositoryProvider));
});

final movieDetailsProvider = FutureProvider.family<MovieDetailsEntity, int>((ref, movieId) {
  return ref.watch(movieRepositoryProvider).getMovieDetails(movieId: movieId);
});

final personDetailsProvider = FutureProvider.family<PersonEntity, int>((ref, personId) {
  return ref.watch(movieRepositoryProvider).getPersonDetails(personId: personId);
});

final personFilmographyProvider =
    FutureProvider.family<PersonFilmographyEntity, int>((ref, personId) {
  return ref.watch(movieRepositoryProvider).getMoviesByPerson(personId: personId);
});

final personSearchProvider = FutureProvider.family<List<PersonEntity>, String>((ref, query) async {
  if (query.trim().length < 2) return const [];
  return ref.watch(movieRepositoryProvider).searchPeople(query: query.trim());
});

final actorGroupReviewsProvider =
    FutureProvider.family<List<ReviewEntity>, int>((ref, personId) async {
  try {
    final filmography = await ref.watch(personFilmographyProvider(personId).future);
    final ids = filmography.allMovies.map((movie) => movie.id).toList();
    if (ids.isEmpty) return const [];
    return ref.read(getMovieGroupReviewsUseCaseProvider).byMovies(ids);
  } catch (_) {
    return const [];
  }
});
