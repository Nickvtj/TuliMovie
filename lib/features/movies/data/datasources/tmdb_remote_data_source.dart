import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/network/tuli_http_client.dart';
import '../../domain/entities/discover_query_entity.dart';
import '../models/movie_details_model.dart';
import '../models/movie_model.dart';
import '../models/person_model.dart';
import '../utils/discover_query_builder.dart';

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

  Future<PaginatedMoviesModel> discoverMovies({
    int page = 1,
    String language = 'pt-BR',
    String watchRegion = 'BR',
    int? withWatchProviderId,
    int? runtimeLteMinutes,
    String? withGenres,
  });

  Future<PaginatedMoviesModel> discoverMoviesQuery(DiscoverQueryEntity query);

  Future<PaginatedMoviesModel> getTrendingMovies({
    int page = 1,
    String language = 'pt-BR',
  });

  Future<PaginatedMoviesModel> getNowPlayingMovies({
    int page = 1,
    String language = 'pt-BR',
    String region = 'BR',
  });

  Future<PaginatedMoviesModel> getTopRatedMovies({
    int page = 1,
    String language = 'pt-BR',
    String region = 'BR',
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

  @override
  Future<PaginatedMoviesModel> discoverMovies({
    int page = 1,
    String language = 'pt-BR',
    String watchRegion = 'BR',
    int? withWatchProviderId,
    int? runtimeLteMinutes,
    String? withGenres,
  }) {
    return discoverMoviesQuery(
      DiscoverQueryEntity(
        page: page,
        language: language,
        watchRegion: watchRegion,
        withWatchProviderIds:
            withWatchProviderId == null ? const [] : [withWatchProviderId],
        runtimeLteMinutes: runtimeLteMinutes,
        withGenres: withGenres == null || withGenres.isEmpty
            ? const []
            : withGenres.split(',').map(int.parse).toList(),
      ),
    );
  }

  @override
  Future<PaginatedMoviesModel> discoverMoviesQuery(DiscoverQueryEntity query) {
    return _getPaginatedMovies(
      '/discover/movie',
      queryParameters: DiscoverQueryBuilder.toQueryParameters(query),
      cacheTtl: const Duration(minutes: 20),
    );
  }

  @override
  Future<PaginatedMoviesModel> getTrendingMovies({
    int page = 1,
    String language = 'pt-BR',
  }) {
    return _getPaginatedMovies(
      '/trending/movie/week',
      queryParameters: {'page': page, 'language': language},
      cacheTtl: const Duration(minutes: 30),
    );
  }

  @override
  Future<PaginatedMoviesModel> getNowPlayingMovies({
    int page = 1,
    String language = 'pt-BR',
    String region = 'BR',
  }) {
    return _getPaginatedMovies(
      '/movie/now_playing',
      queryParameters: {'page': page, 'language': language, 'region': region},
      cacheTtl: const Duration(minutes: 30),
    );
  }

  @override
  Future<PaginatedMoviesModel> getTopRatedMovies({
    int page = 1,
    String language = 'pt-BR',
    String region = 'BR',
  }) {
    return _getPaginatedMovies(
      '/movie/top_rated',
      queryParameters: {'page': page, 'language': language, 'region': region},
      cacheTtl: const Duration(hours: 2),
    );
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
