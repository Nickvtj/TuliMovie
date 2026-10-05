import 'package:get_it/get_it.dart';

import '../../features/movies/data/datasources/tmdb_remote_data_source.dart';
import '../../features/movies/data/repositories/movie_repository_impl.dart';
import '../../features/movies/domain/repositories/movie_repository.dart';
import '../network/tuli_http_client.dart';
import '../services/base_firestore_service.dart';
import '../services/i_base_firestore_service.dart';

final GetIt sl = GetIt.instance;

/// Registra dependências de infraestrutura e domínio (singletons).
Future<void> configureDependencies() async {
  if (sl.isRegistered<TuliHttpClient>()) return;

  sl
    ..registerLazySingleton<TuliHttpClient>(TuliHttpClient.new)
    ..registerLazySingleton<IBaseFirestoreService>(
      () => BaseFirestoreService(),
    )
    ..registerLazySingleton<TmdbRemoteDataSource>(
      () => TmdbRemoteDataSourceImpl(sl<TuliHttpClient>()),
    )
    ..registerLazySingleton<MovieRepository>(
      () => MovieRepositoryImpl(sl<TmdbRemoteDataSource>()),
    );
}
