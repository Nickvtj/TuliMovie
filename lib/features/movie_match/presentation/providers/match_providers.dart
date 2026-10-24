import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/match_room_entity.dart';
import '../../domain/repositories/match_room_repository.dart';
import '../../domain/usecases/load_more_match_candidates_use_case.dart';
import '../../domain/usecases/pick_match_candidates_use_case.dart';
import '../notifiers/match_deck_notifier.dart';

final matchRoomRepositoryProvider = Provider<MatchRoomRepository>(
  (ref) => sl<MatchRoomRepository>(),
);

final pickMatchCandidatesUseCaseProvider = Provider(
  (ref) => sl<PickMatchCandidatesUseCase>(),
);

final loadMoreMatchCandidatesUseCaseProvider = Provider(
  (ref) => sl<LoadMoreMatchCandidatesUseCase>(),
);

final matchRoomStreamProvider = StreamProvider.family<MatchRoomEntity?, String>((ref, roomId) {
  return ref.watch(matchRoomRepositoryProvider).watchRoom(roomId);
});

final matchLikesStreamProvider =
    StreamProvider.family<Map<String, Map<int, bool>>, String>((ref, roomId) {
  return ref.watch(matchRoomRepositoryProvider).watchLikes(roomId);
});

/// Baralho do usuário logado na sala, sincronizado com a sala e os votos.
final matchDeckProvider =
    StateNotifierProvider.autoDispose.family<MatchDeckNotifier, MatchDeckState, String>(
        (ref, roomId) {
  final notifier = MatchDeckNotifier(
    userId: ref.watch(authSessionProvider.select((s) => s.valueOrNull?.id)) ?? '',
    loadMore: ref.watch(loadMoreMatchCandidatesUseCaseProvider),
  );

  void sync() {
    final room = ref.read(matchRoomStreamProvider(roomId)).valueOrNull;
    final likes = ref.read(matchLikesStreamProvider(roomId)).valueOrNull;
    if (room != null && likes != null) notifier.sync(room, likes);
  }

  ref
    ..listen(matchRoomStreamProvider(roomId), (_, __) => sync())
    ..listen(matchLikesStreamProvider(roomId), (_, __) => sync());
  sync();

  return notifier;
});
