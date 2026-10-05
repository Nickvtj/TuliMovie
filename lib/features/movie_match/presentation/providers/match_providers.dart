import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/match_room_entity.dart';
import '../../domain/repositories/match_room_repository.dart';
import '../../domain/usecases/pick_match_candidates_use_case.dart';

final matchRoomRepositoryProvider = Provider<MatchRoomRepository>(
  (ref) => sl<MatchRoomRepository>(),
);

final pickMatchCandidatesUseCaseProvider = Provider(
  (ref) => sl<PickMatchCandidatesUseCase>(),
);

final matchRoomStreamProvider = StreamProvider.family<MatchRoomEntity?, String>((ref, roomId) {
  return ref.watch(matchRoomRepositoryProvider).watchRoom(roomId);
});

final matchLikesStreamProvider =
    StreamProvider.family<Map<String, Map<int, bool>>, String>((ref, roomId) {
  return ref.watch(matchRoomRepositoryProvider).watchLikes(roomId);
});
