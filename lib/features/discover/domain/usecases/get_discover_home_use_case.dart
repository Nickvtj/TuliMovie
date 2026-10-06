import '../../../movies/domain/repositories/movie_repository.dart';
import '../entities/discover_home_entity.dart';

class GetDiscoverHomeUseCase {
  const GetDiscoverHomeUseCase(this._movies);

  final MovieRepository _movies;

  Future<DiscoverHomeEntity> call() async {
    final results = await Future.wait([
      _movies.getTrendingMovies(),
      _movies.getNowPlayingMovies(),
      _movies.getTopRatedMovies(),
      _movies.discoverMovies(page: 1),
    ]);

    return DiscoverHomeEntity(
      sections: [
        DiscoverSectionEntity(
          id: 'trending',
          title: 'Em alta esta semana',
          subtitle: 'O que o mundo está assistindo',
          movies: results[0],
        ),
        DiscoverSectionEntity(
          id: 'now_playing',
          title: 'Nos cinemas',
          subtitle: 'Estreias e cartaz no Brasil',
          movies: results[1],
        ),
        DiscoverSectionEntity(
          id: 'top_rated',
          title: 'Melhores notas',
          subtitle: 'Clássicos e favoritos da crítica',
          movies: results[2],
        ),
        DiscoverSectionEntity(
          id: 'discover',
          title: 'Para você explorar',
          subtitle: 'Sugestões populares no TMDB',
          movies: results[3],
        ),
      ],
    );
  }
}
