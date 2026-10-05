import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import '../../features/auth/data/datasources/user_firestore_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_with_email_use_case.dart';
import '../../features/auth/domain/usecases/register_use_case.dart';
import '../../features/auth/domain/usecases/sign_out_use_case.dart';
import '../../features/feed/data/datasources/review_firestore_data_source.dart';
import '../../features/feed/data/repositories/review_repository_impl.dart';
import '../../features/feed/domain/repositories/review_repository.dart';
import '../../features/feed/domain/usecases/get_feed_page_use_case.dart';
import '../../features/feed/domain/usecases/get_movie_group_reviews_use_case.dart';
import '../../features/feed/domain/usecases/toggle_review_reaction_use_case.dart';
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
    )
    ..registerLazySingleton<FirebaseAuthRemoteDataSource>(
      FirebaseAuthRemoteDataSourceImpl.new,
    )
    ..registerLazySingleton<UserFirestoreDataSource>(
      () => UserFirestoreDataSourceImpl(sl<IBaseFirestoreService>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        authRemote: sl<FirebaseAuthRemoteDataSource>(),
        userFirestore: sl<UserFirestoreDataSource>(),
      ),
    )
    ..registerLazySingleton(() => LoginWithEmailUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()))
    ..registerLazySingleton<ReviewFirestoreDataSource>(
      ReviewFirestoreDataSourceImpl.new,
    )
    ..registerLazySingleton<ReviewRepository>(
      () => ReviewRepositoryImpl(sl<ReviewFirestoreDataSource>()),
    )
    ..registerLazySingleton(() => GetFeedPageUseCase(sl<ReviewRepository>()))
    ..registerLazySingleton(() => GetMovieGroupReviewsUseCase(sl<ReviewRepository>()))
    ..registerLazySingleton(() => ToggleReviewReactionUseCase(sl<ReviewRepository>()));
}
