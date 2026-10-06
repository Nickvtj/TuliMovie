import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../movies/domain/repositories/movie_repository.dart';
import '../../domain/entities/discover_home_entity.dart';
import '../../domain/usecases/get_discover_home_use_case.dart';

final getDiscoverHomeUseCaseProvider = Provider<GetDiscoverHomeUseCase>(
  (ref) => GetDiscoverHomeUseCase(sl<MovieRepository>()),
);

final discoverHomeProvider = FutureProvider.autoDispose<DiscoverHomeEntity>((ref) {
  return ref.watch(getDiscoverHomeUseCaseProvider).call();
});
