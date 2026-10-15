import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/awards/domain/services/tuli_awards_calculator.dart';
import 'package:tulimovie/features/feed/domain/entities/review_entity.dart';
import 'package:tulimovie/features/feed/domain/entities/review_participant_entity.dart';

ReviewEntity _review({
  required int movieId,
  required double rating,
  List<String> companions = const [],
  int year = 2026,
}) {
  return ReviewEntity(
    id: 'r$movieId-$year',
    tmdbMovieId: movieId,
    movieTitle: 'Filme $movieId',
    participants: [
      ReviewParticipantEntity(userId: 'me', displayName: 'Eu', rating: rating),
      for (final id in companions)
        ReviewParticipantEntity(
          userId: id,
          displayName: id.toUpperCase(),
          rating: 0,
          hasSubmittedRating: false,
        ),
    ],
    groupAverageRating: rating,
    createdAt: DateTime(year, 5, 1),
    authorId: 'me',
  );
}

void main() {
  final awards = TuliAwardsCalculator.build(
    year: 2026,
    userId: 'me',
    reviews: [
      _review(movieId: 1, rating: 3, companions: ['ana', 'bia']),
      _review(movieId: 2, rating: 5, companions: ['ana']),
      _review(movieId: 3, rating: 4),
      _review(movieId: 4, rating: 1, year: 2025),
    ],
  );

  test('conta só o ano pedido e ordena o Top pela minha nota', () {
    expect(awards.totalMovies, 3);
    expect(awards.topMovies.map((m) => m.tmdbMovieId), [2, 3, 1]);
    expect(awards.averageRating, 4.0);
  });

  test('ranqueia quem mais assistiu comigo', () {
    expect(awards.companions.map((c) => c.userId), ['ana', 'bia']);
    expect(awards.companions.first.sessionCount, 2);
    expect(awards.companions.first.displayName, 'ANA');
  });
}
