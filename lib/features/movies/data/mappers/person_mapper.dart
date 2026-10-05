import '../../domain/entities/person_entity.dart';
import '../models/movie_model.dart';
import '../models/person_model.dart';
import 'movie_mapper.dart';

abstract final class PersonMapper {
  static PersonEntity toEntity(PersonModel model) {
    return PersonEntity(
      id: model.id,
      name: model.name,
      biography: model.biography,
      profilePath: model.profilePath,
      knownForDepartment: model.knownForDepartment,
      birthday: model.birthday,
      placeOfBirth: model.placeOfBirth,
    );
  }

  static List<PersonEntity> toEntityList(List<PersonModel> models) =>
      models.map(toEntity).toList();

  static PersonFilmographyEntity filmographyToEntity({
    required PersonModel person,
    required List<MovieModel> cast,
    required List<MovieModel> crew,
  }) {
    return PersonFilmographyEntity(
      person: toEntity(person),
      castMovies: MovieMapper.toEntityList(cast),
      crewMovies: MovieMapper.toEntityList(crew),
    );
  }

}
