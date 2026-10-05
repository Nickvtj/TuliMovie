import 'package:equatable/equatable.dart';

import 'movie_entity.dart';

class PersonEntity extends Equatable {
  const PersonEntity({
    required this.id,
    required this.name,
    this.biography,
    this.profilePath,
    this.knownForDepartment,
    this.birthday,
    this.placeOfBirth,
  });

  final int id;
  final String name;
  final String? biography;
  final String? profilePath;
  final String? knownForDepartment;
  final String? birthday;
  final String? placeOfBirth;

  @override
  List<Object?> get props => [
        id,
        name,
        biography,
        profilePath,
        knownForDepartment,
        birthday,
        placeOfBirth,
      ];
}

class PersonFilmographyEntity extends Equatable {
  const PersonFilmographyEntity({
    required this.person,
    required this.castMovies,
    required this.crewMovies,
  });

  final PersonEntity person;
  final List<MovieEntity> castMovies;
  final List<MovieEntity> crewMovies;

  List<MovieEntity> get allMovies {
    final map = <int, MovieEntity>{};
    for (final movie in [...castMovies, ...crewMovies]) {
      map[movie.id] = movie;
    }
    return map.values.toList()
      ..sort((a, b) => (b.releaseDate ?? '').compareTo(a.releaseDate ?? ''));
  }

  @override
  List<Object?> get props => [person, castMovies, crewMovies];
}
