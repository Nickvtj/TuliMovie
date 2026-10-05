import 'package:equatable/equatable.dart';

/// Filme resumido (busca / listagens TMDB).
class MovieEntity extends Equatable {
  const MovieEntity({
    required this.id,
    required this.title,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage = 0,
    this.genreIds = const [],
  });

  final int id;
  final String title;
  final String? originalTitle;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final List<int> genreIds;

  @override
  List<Object?> get props => [
        id,
        title,
        originalTitle,
        overview,
        posterPath,
        backdropPath,
        releaseDate,
        voteAverage,
        genreIds,
      ];
}
