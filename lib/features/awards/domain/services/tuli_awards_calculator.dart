import '../../../feed/domain/entities/review_entity.dart';
import '../entities/tuli_awards_entity.dart';

abstract final class TuliAwardsCalculator {
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

  static TuliAwardsEntity build({
    required int year,
    required List<ReviewEntity> reviews,
  }) {
    final yearReviews = reviews.where((r) => r.createdAt.year == year).toList();

    final movieBuckets = <int, List<double>>{};
    final movieMeta = <int, ReviewEntity>{};

    for (final review in yearReviews) {
      movieBuckets.putIfAbsent(review.tmdbMovieId, () => []).add(review.groupAverageRating);
      movieMeta[review.tmdbMovieId] = review;
    }

    final topMovies = movieBuckets.entries.map((entry) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      final meta = movieMeta[entry.key]!;
      return AwardsTopMovieEntity(
        tmdbMovieId: entry.key,
        title: meta.movieTitle,
        posterPath: meta.moviePosterPath,
        averageRating: double.parse(avg.toStringAsFixed(2)),
        reviewCount: entry.value.length,
      );
    }).toList()
      ..sort((a, b) => b.averageRating.compareTo(a.averageRating));

    final criticAverages = <String, List<double>>{};
    for (final review in yearReviews) {
      for (final participant in review.participants.where((p) => p.hasSubmittedRating)) {
        criticAverages.putIfAbsent(participant.userId, () => []).add(participant.rating);
      }
    }

    var hardestName = '—';
    double? lowestAvg;
    for (final entry in criticAverages.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (lowestAvg == null || avg < lowestAvg!) {
        lowestAvg = avg;
        hardestName = yearReviews
            .expand((review) => review.participants)
            .firstWhere((p) => p.userId == entry.key)
            .displayName;
      }
    }

    return TuliAwardsEntity(
      year: year,
      totalMovies: yearReviews.length,
      totalHoursEstimate: yearReviews.length * 2.0,
      topMovies: topMovies.take(5).toList(),
      hardestCriticName: hardestName,
      categories: comicCategories,
    );
  }
}
