import 'package:equatable/equatable.dart';

class MatchCandidateEntity extends Equatable {
  const MatchCandidateEntity({
    required this.tmdbMovieId,
    required this.title,
    this.posterPath,
    this.overview,
    this.releaseYear,
  });

  final int tmdbMovieId;
  final String title;
  final String? posterPath;
  final String? overview;
  final int? releaseYear;

  @override
  List<Object?> get props => [tmdbMovieId, title, posterPath, overview, releaseYear];
}
