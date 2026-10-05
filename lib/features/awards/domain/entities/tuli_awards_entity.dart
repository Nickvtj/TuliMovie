import 'package:equatable/equatable.dart';

class AwardsTopMovieEntity extends Equatable {
  const AwardsTopMovieEntity({
    required this.tmdbMovieId,
    required this.title,
    this.posterPath,
    required this.averageRating,
    required this.reviewCount,
  });

  final int tmdbMovieId;
  final String title;
  final String? posterPath;
  final double averageRating;
  final int reviewCount;

  @override
  List<Object?> get props => [tmdbMovieId, title, posterPath, averageRating, reviewCount];
}

class ComicCategoryEntity extends Equatable {
  const ComicCategoryEntity({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;

  @override
  List<Object?> get props => [id, title, subtitle];
}

class TuliAwardsEntity extends Equatable {
  const TuliAwardsEntity({
    required this.year,
    required this.totalMovies,
    required this.totalHoursEstimate,
    required this.topMovies,
    required this.hardestCriticName,
    required this.categories,
  });

  final int year;
  final int totalMovies;
  final double totalHoursEstimate;
  final List<AwardsTopMovieEntity> topMovies;
  final String hardestCriticName;
  final List<ComicCategoryEntity> categories;

  @override
  List<Object?> get props => [
        year,
        totalMovies,
        totalHoursEstimate,
        topMovies,
        hardestCriticName,
        categories,
      ];
}
