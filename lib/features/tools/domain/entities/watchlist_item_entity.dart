import 'package:equatable/equatable.dart';

class WatchlistItemEntity extends Equatable {
  const WatchlistItemEntity({
    required this.id,
    required this.tmdbMovieId,
    required this.title,
    this.posterPath,
  });

  final String id;
  final int tmdbMovieId;
  final String title;
  final String? posterPath;

  @override
  List<Object?> get props => [id, tmdbMovieId, title, posterPath];
}
