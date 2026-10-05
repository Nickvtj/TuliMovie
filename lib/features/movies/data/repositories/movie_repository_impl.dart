import '../../../../core/config/env_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/movie_details_entity.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/person_entity.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/tmdb_remote_data_source.dart';
import '../mappers/movie_mapper.dart';
import '../mappers/person_mapper.dart';

class MovieRepositoryImpl implements MovieRepository {
  MovieRepositoryImpl(this._remoteDataSource);

  final TmdbRemoteDataSource _remoteDataSource;

  @override
  Future<List<MovieEntity>> searchMovies({
    required String query,
    int page = 1,
    String language = 'pt-BR',
  }) async {
    _ensureQuery(query);
    try {
      final result = await _remoteDataSource.searchMovies(
        query: query.trim(),
        page: page,
        language: language,
      );
      return MovieMapper.toEntityList(result.results);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Falha ao buscar filmes.', cause: e);
    }
  }

  @override
  Future<MovieDetailsEntity> getMovieDetails({
    required int movieId,
    String language = 'pt-BR',
    String watchRegion = EnvConfig.tmdbDefaultRegion,
  }) async {
    try {
      final model = await _remoteDataSource.getMovieDetails(
        movieId: movieId,
        language: language,
      );
      return MovieMapper.detailsToEntity(model, watchRegion: watchRegion);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Falha ao carregar detalhes do filme.', cause: e);
    }
  }

  @override
  Future<List<PersonEntity>> searchPeople({
    required String query,
    int page = 1,
    String language = 'pt-BR',
  }) async {
    _ensureQuery(query);
    try {
      final result = await _remoteDataSource.searchPeople(
        query: query.trim(),
        page: page,
        language: language,
      );
      return PersonMapper.toEntityList(result.results);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Falha ao buscar pessoas.', cause: e);
    }
  }

  @override
  Future<PersonEntity> getPersonDetails({
    required int personId,
    String language = 'pt-BR',
  }) async {
    try {
      final model = await _remoteDataSource.getPersonDetails(
        personId: personId,
        language: language,
      );
      return PersonMapper.toEntity(model);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Falha ao carregar perfil.', cause: e);
    }
  }

  @override
  Future<PersonFilmographyEntity> getMoviesByPerson({
    required int personId,
    String language = 'pt-BR',
  }) async {
    try {
      final person = await _remoteDataSource.getPersonDetails(
        personId: personId,
        language: language,
      );
      final credits = await _remoteDataSource.getPersonMovieCredits(
        personId: personId,
        language: language,
      );

      return PersonMapper.filmographyToEntity(
        person: person,
        cast: credits.cast,
        crew: credits.crew,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Falha ao carregar filmografia.', cause: e);
    }
  }

  void _ensureQuery(String query) {
    if (query.trim().length < 2) {
      throw const AppException(
        message: 'Digite ao menos 2 caracteres para buscar.',
        type: AppExceptionType.validation,
      );
    }
  }
}
