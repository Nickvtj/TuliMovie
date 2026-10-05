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
import '../../features/reviews/data/repositories/group_members_repository_impl.dart';
import '../../features/reviews/data/repositories/review_write_repository_impl.dart';
import '../../features/reviews/domain/repositories/group_members_repository.dart';
import '../../features/reviews/domain/repositories/review_write_repository.dart';
import '../../features/reviews/domain/usecases/create_review_use_case.dart';
import '../../features/reviews/domain/usecases/list_group_members_use_case.dart';
import '../../features/awards/data/datasources/awards_firestore_data_source.dart';
import '../../features/awards/data/repositories/awards_repository_impl.dart';
import '../../features/awards/domain/repositories/awards_repository.dart';
import '../../features/awards/domain/usecases/get_tuli_awards_use_case.dart';
import '../../features/awards/domain/usecases/vote_comic_category_use_case.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_dashboard_use_case.dart';
import '../../features/share/domain/usecases/share_review_card_use_case.dart';
import '../notifications/push_notification_service.dart';
import '../services/image_export_service.dart';
import '../../features/movie_match/data/datasources/match_room_firestore_data_source.dart';
import '../../features/movie_match/data/repositories/match_room_repository_impl.dart';
import '../../features/movie_match/domain/repositories/match_room_repository.dart';
import '../../features/movie_match/domain/usecases/pick_match_candidates_use_case.dart';
import '../../features/tools/data/datasources/cinepass_firestore_data_source.dart';
import '../../features/tools/data/datasources/watchlist_firestore_data_source.dart';
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
    ..registerLazySingleton(() => ToggleReviewReactionUseCase(sl<ReviewRepository>()))
    ..registerLazySingleton<GroupMembersRepository>(
      () => GroupMembersRepositoryImpl(sl<UserFirestoreDataSource>()),
    )
    ..registerLazySingleton<ReviewWriteRepository>(
      () => ReviewWriteRepositoryImpl(sl<ReviewFirestoreDataSource>()),
    )
    ..registerLazySingleton(() => ListGroupMembersUseCase(sl<GroupMembersRepository>()))
    ..registerLazySingleton(() => CreateReviewUseCase(sl<ReviewWriteRepository>()))
    ..registerLazySingleton<MatchRoomFirestoreDataSource>(
      MatchRoomFirestoreDataSource.new,
    )
    ..registerLazySingleton<MatchRoomRepository>(
      () => MatchRoomRepositoryImpl(sl<MatchRoomFirestoreDataSource>()),
    )
    ..registerLazySingleton(
      () => PickMatchCandidatesUseCase(
        movieRepository: sl<MovieRepository>(),
        reviewRepository: sl<ReviewRepository>(),
      ),
    )
    ..registerLazySingleton<WatchlistFirestoreDataSource>(
      WatchlistFirestoreDataSource.new,
    )
    ..registerLazySingleton<CinepassFirestoreDataSource>(
      CinepassFirestoreDataSource.new,
    )
    ..registerLazySingleton<PushNotificationService>(PushNotificationService.new)
    ..registerLazySingleton<ImageExportService>(ImageExportService.new)
    ..registerLazySingleton(() => ShareReviewCardUseCase(sl<ImageExportService>()))
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<ReviewFirestoreDataSource>()),
    )
    ..registerLazySingleton(() => GetProfileDashboardUseCase(sl<ProfileRepository>()))
    ..registerLazySingleton<AwardsFirestoreDataSource>(AwardsFirestoreDataSource.new)
    ..registerLazySingleton<AwardsRepository>(
      () => AwardsRepositoryImpl(sl<AwardsFirestoreDataSource>()),
    )
    ..registerLazySingleton(() => GetTuliAwardsUseCase(sl<ReviewRepository>()))
    ..registerLazySingleton(() => VoteComicCategoryUseCase(sl<AwardsRepository>()));
}
