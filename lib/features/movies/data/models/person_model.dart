import 'movie_model.dart';

class PersonModel {
  const PersonModel({
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

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      biography: json['biography'] as String?,
      profilePath: json['profile_path'] as String?,
      knownForDepartment: json['known_for_department'] as String?,
      birthday: json['birthday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
    );
  }
}

class PaginatedPeopleModel {
  const PaginatedPeopleModel({required this.results});

  final List<PersonModel> results;

  factory PaginatedPeopleModel.fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PersonModel.fromJson)
        .toList();
    return PaginatedPeopleModel(results: results);
  }
}

class PersonMovieCreditsModel {
  const PersonMovieCreditsModel({
    required this.cast,
    required this.crew,
  });

  final List<MovieModel> cast;
  final List<MovieModel> crew;

  factory PersonMovieCreditsModel.fromJson(Map<String, dynamic> json) {
    List<MovieModel> parse(String key) {
      return (json[key] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(MovieModel.fromJson)
          .toList();
    }

    return PersonMovieCreditsModel(
      cast: parse('cast'),
      crew: parse('crew'),
    );
  }
}
