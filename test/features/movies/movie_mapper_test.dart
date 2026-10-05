import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/movies/data/mappers/movie_mapper.dart';
import 'package:tulimovie/features/movies/data/models/movie_model.dart';
import 'package:tulimovie/features/movies/data/models/watch_providers_model.dart';

void main() {
  test('MovieMapper converte model básico em entity', () {
    const model = MovieModel(
      id: 603,
      title: 'Matrix',
      overview: 'Neo...',
      posterPath: '/poster.jpg',
      voteAverage: 8.2,
    );

    final entity = MovieMapper.toEntity(model);

    expect(entity.id, 603);
    expect(entity.title, 'Matrix');
    expect(entity.voteAverage, 8.2);
  });

  test('MovieMapper extrai streaming por região', () {
    final payload = WatchProvidersPayloadModel.fromJson({
      'results': {
        'BR': {
          'flatrate': [
            {
              'provider_id': 8,
              'provider_name': 'Netflix',
              'logo_path': '/netflix.png',
            },
          ],
        },
      },
    });

    final providers = MovieMapper.providersForRegion(payload, 'BR');

    expect(providers, isNotEmpty);
    expect(providers.first.name, 'Netflix');
  });
}
