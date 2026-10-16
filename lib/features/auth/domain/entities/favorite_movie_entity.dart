import 'package:equatable/equatable.dart';

/// Filme fixado no "Top 4" do perfil (dados copiados para exibir sem chamar o TMDB).
class FavoriteMovieEntity extends Equatable {
  const FavoriteMovieEntity({
    required this.tmdbMovieId,
    required this.title,
    this.posterPath,
  });

  final int tmdbMovieId;
  final String title;
  final String? posterPath;

  @override
  List<Object?> get props => [tmdbMovieId, title, posterPath];
}
