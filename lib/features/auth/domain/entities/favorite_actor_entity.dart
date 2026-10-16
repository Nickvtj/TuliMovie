import 'package:equatable/equatable.dart';

/// Ator fixado no "Top 4" do perfil (dados copiados para exibir sem chamar o TMDB).
class FavoriteActorEntity extends Equatable {
  const FavoriteActorEntity({
    required this.personId,
    required this.name,
    this.profilePath,
  });

  final int personId;
  final String name;
  final String? profilePath;

  @override
  List<Object?> get props => [personId, name, profilePath];
}
