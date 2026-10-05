import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/tuli_awards_entity.dart';
import '../../domain/repositories/awards_repository.dart';
import '../../domain/usecases/get_tuli_awards_use_case.dart';
import '../../domain/usecases/vote_comic_category_use_case.dart';

final awardsRepositoryProvider = Provider<AwardsRepository>(
  (ref) => sl<AwardsRepository>(),
);

final getTuliAwardsUseCaseProvider = Provider(
  (ref) => sl<GetTuliAwardsUseCase>(),
);

final voteComicCategoryUseCaseProvider = Provider(
  (ref) => VoteComicCategoryUseCase(ref.watch(awardsRepositoryProvider)),
);

final tuliAwardsProvider = FutureProvider.family<TuliAwardsEntity, int>((ref, year) {
  return ref.watch(getTuliAwardsUseCaseProvider).call(year: year);
});

final comicVotesProvider = FutureProvider.family<Map<String, String>, int>((ref, year) {
  return ref.watch(awardsRepositoryProvider).fetchVotesForYear(year);
});

final awardsYearProvider = Provider<int>((_) => DateTime.now().year);
