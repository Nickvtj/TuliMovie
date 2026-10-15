import '../../../feed/domain/entities/review_entity.dart';
import '../../../feed/domain/entities/review_participant_entity.dart';
import '../entities/tuli_awards_entity.dart';

abstract final class TuliAwardsCalculator {
  static const topMoviesCount = 5;
  static const companionsCount = 5;
  static const hoursPerMovie = 2.0;

  static const comicCategories = [
    ComicCategoryEntity(
      id: 'worst_movie',
      title: 'Pior Filme do Ano',
      subtitle: 'O trauma coletivo da turma',
    ),
    ComicCategoryEntity(
      id: 'biggest_disappointment',
      title: 'Maior Decepção',
      subtitle: 'Expectativa de trailer vs realidade',
    ),
    ComicCategoryEntity(
      id: 'marketing_director',
      title: 'Diretor de Marketing',
      subtitle: 'Defendeu filme ruim com unhas e dentes',
    ),
  ];

  /// Retrospectiva de [userId] a partir das avaliações que ele publicou.
  static TuliAwardsEntity build({
    required int year,
    required String userId,
    required List<ReviewEntity> reviews,
  }) {
    final yearReviews = reviews.where((r) => r.createdAt.year == year).toList();

    final ratingsByMovie = <int, List<double>>{};
    final movieMeta = <int, ReviewEntity>{};
    final allRatings = <double>[];

    for (final review in yearReviews) {
      final rating = _ratingOf(userId, review);
      if (rating == null) continue;
      ratingsByMovie.putIfAbsent(review.tmdbMovieId, () => []).add(rating);
      movieMeta[review.tmdbMovieId] = review;
      allRatings.add(rating);
    }

    final topMovies = ratingsByMovie.entries.map((entry) {
      final meta = movieMeta[entry.key]!;
      return AwardsTopMovieEntity(
        tmdbMovieId: entry.key,
        title: meta.movieTitle,
        posterPath: meta.moviePosterPath,
        averageRating: _round(_average(entry.value)),
        reviewCount: entry.value.length,
      );
    }).toList()
      ..sort((a, b) => b.averageRating.compareTo(a.averageRating));

    final totalMovies = yearReviews.map((r) => r.tmdbMovieId).toSet().length;

    return TuliAwardsEntity(
      year: year,
      totalMovies: totalMovies,
      totalHoursEstimate: totalMovies * hoursPerMovie,
      topMovies: topMovies.take(topMoviesCount).toList(),
      averageRating: allRatings.isEmpty ? null : _round(_average(allRatings)),
      companions: _companions(userId, yearReviews),
      categories: comicCategories,
    );
  }

  static List<AwardsCompanionEntity> _companions(String userId, List<ReviewEntity> reviews) {
    final counts = <String, int>{};
    final latest = <String, ReviewParticipantEntity>{};

    for (final review in reviews) {
      final friends = review.participants.where((p) => p.userId != userId);
      for (final friend in friends.map((p) => p.userId).toSet()) {
        counts[friend] = (counts[friend] ?? 0) + 1;
      }
      for (final participant in friends) {
        latest.putIfAbsent(participant.userId, () => participant);
      }
    }

    final ranking = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ranking.take(companionsCount).map((entry) {
      final participant = latest[entry.key]!;
      return AwardsCompanionEntity(
        userId: entry.key,
        displayName: participant.displayName,
        photoUrl: participant.photoUrl,
        sessionCount: entry.value,
      );
    }).toList();
  }

  static double? _ratingOf(String userId, ReviewEntity review) {
    for (final participant in review.participants) {
      if (participant.userId == userId && participant.hasSubmittedRating) {
        return participant.rating;
      }
    }
    return null;
  }

  static double _average(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;

  static double _round(double value) => double.parse(value.toStringAsFixed(2));
}
