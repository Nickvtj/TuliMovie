import 'package:equatable/equatable.dart';

class WatchedMovieEntity extends Equatable {
  const WatchedMovieEntity({
    required this.tmdbMovieId,
    required this.title,
    this.posterPath,
    required this.watchedAt,
    this.source = WatchedMovieSource.discover,
  });

  final int tmdbMovieId;
  final String title;
  final String? posterPath;
  final DateTime watchedAt;
  final WatchedMovieSource source;

  @override
  List<Object?> get props => [tmdbMovieId, title, posterPath, watchedAt, source];
}

enum WatchedMovieSource {
  discover,
  review,
}
