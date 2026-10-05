import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/network/tuli_http_client.dart';
import '../models/movie_details_model.dart';
import '../models/movie_model.dart';
import '../models/person_model.dart';

/// Contrato de acesso HTTP ao TMDB (implementação única — mockável nos testes).
abstract interface class TmdbRemoteDataSource {
  Future<PaginatedMoviesModel> searchMovies({
    required String query,
    int page = 1,
    String language = 'pt-BR',
  });

  Future<MovieDetailsModel> getMovieDetails({
    required int movieId,
    String language = 'pt-BR',
  });

  Future<PaginatedPeopleModel> searchPeople({
    required String query,
    int page = 1,
    String language = 'pt-BR',
  });

  Future<PersonModel> getPersonDetails({
    required int personId,
    String language = 'pt-BR',
  });

  Future<PersonMovieCreditsModel> getPersonMovieCredits({
    required int personId,
    String language = 'pt-BR',
  });
}

class TmdbRemoteDataSourceImpl implements TmdbRemoteDataSource {
  TmdbRemoteDataSourceImpl(this._client);

  final TuliHttpClient _client;

  @override
  Future<PaginatedMoviesModel> searchMovies({
    required String query,
    int page = 1,
    String language = 'pt-BR',
  }) async {
    return _getPaginatedMovies(
      '/search/movie',
      queryParameters: {
        'query': query,
        'page': page,
        'language': language,
        'include_adult': false,
      },
      cacheTtl: const Duration(minutes: 5),
    );
  }

  @override
  Future<MovieDetailsModel> getMovieDetails({
    required int movieId,
    String language = 'pt-BR',
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/movie/$movieId',
        queryParameters: {
          'language': language,
          'append_to_response': 'credits,watch/providers',
        },
        cacheTtl: const Duration(hours: 6),
      );

      final data = response.data;
      if (data == null) {
        throw const FormatException('Resposta TMDB vazia em getMovieDetails');
      }
      return MovieDetailsModel.fromJson(data);
    } catch (e) {
      throw DioExceptionMapper.extract(e);
    }
  }

  @override
  Future<PaginatedPeopleModel> searchPeople({
    required String query,
    int page = 1,
    String language = 'pt-BR',
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/search/person',
        queryParameters: {
          'query': query,
          'page': page,
          'language': language,
          'include_adult': false,
        },
        cacheTtl: const Duration(minutes: 10),
      );

      final data = response.data;
      if (data == null) {
        throw const FormatException('Resposta TMDB vazia em searchPeople');
      }
      return PaginatedPeopleModel.fromJson(data);
    } catch (e) {
      throw DioExceptionMapper.extract(e);
    }
  }

  @override
  Future<PersonModel> getPersonDetails({
    required int personId,
    String language = 'pt-BR',
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/person/$personId',
        queryParameters: {'language': language},
        cacheTtl: const Duration(hours: 12),
      );

      final data = response.data;
      if (data == null) {
        throw const FormatException('Resposta TMDB vazia em getPersonDetails');
      }
      return PersonModel.fromJson(data);
    } catch (e) {
      throw DioExceptionMapper.extract(e);
    }
  }

  @override
  Future<PersonMovieCreditsModel> getPersonMovieCredits({
    required int personId,
    String language = 'pt-BR',
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/person/$personId/movie_credits',
        queryParameters: {'language': language},
        cacheTtl: const Duration(hours: 6),
      );

      final data = response.data;
      if (data == null) {
        throw const FormatException('Resposta TMDB vazia em getPersonMovieCredits');
      }
      return PersonMovieCreditsModel.fromJson(data);
    } catch (e) {
      throw DioExceptionMapper.extract(e);
    }
  }

  Future<PaginatedMoviesModel> _getPaginatedMovies(
    String path, {
    required Map<String, dynamic> queryParameters,
    Duration? cacheTtl,
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        cacheTtl: cacheTtl,
      );

      final data = response.data;
      if (data == null) {
        throw const FormatException('Resposta TMDB vazia em searchMovies');
      }
      return PaginatedMoviesModel.fromJson(data);
    } catch (e) {
      throw DioExceptionMapper.extract(e);
    }
  }
}
