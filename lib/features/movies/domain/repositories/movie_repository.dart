import '../entities/movie_details_entity.dart';
import '../entities/movie_entity.dart';
import '../entities/person_entity.dart';

/// Contrato de domínio — presentation depende disto, não do TMDB.
abstract interface class MovieRepository {
  Future<List<MovieEntity>> searchMovies({
    required String query,
    int page = 1,
    String language = 'pt-BR',
  });

  Future<MovieDetailsEntity> getMovieDetails({
    required int movieId,
    String language = 'pt-BR',
    String watchRegion = 'BR',
  });

  Future<List<PersonEntity>> searchPeople({
    required String query,
    int page = 1,
    String language = 'pt-BR',
  });

  Future<PersonEntity> getPersonDetails({
    required int personId,
    String language = 'pt-BR',
  });

  Future<PersonFilmographyEntity> getMoviesByPerson({
    required int personId,
    String language = 'pt-BR',
  });
}
