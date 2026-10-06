import '../entities/discover_query_entity.dart';
import '../entities/movie_details_entity.dart';
import '../entities/movie_entity.dart';
import '../entities/person_entity.dart';

class DiscoverMoviesPageResult {
  const DiscoverMoviesPageResult({
    required this.movies,
    required this.page,
    required this.hasMore,
  });

  final List<MovieEntity> movies;
  final int page;
  final bool hasMore;
}

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

  Future<List<MovieEntity>> discoverMovies({
    int page = 1,
    String language = 'pt-BR',
    String watchRegion = 'BR',
    int? withWatchProviderId,
    int? runtimeLteMinutes,
    String? withGenres,
  });

  Future<DiscoverMoviesPageResult> discoverMoviesQuery(DiscoverQueryEntity query);

  Future<List<MovieEntity>> getTrendingMovies({int page = 1, String language = 'pt-BR'});

  Future<List<MovieEntity>> getNowPlayingMovies({
    int page = 1,
    String language = 'pt-BR',
    String region = 'BR',
  });

  Future<List<MovieEntity>> getTopRatedMovies({
    int page = 1,
    String language = 'pt-BR',
    String region = 'BR',
  });
}
