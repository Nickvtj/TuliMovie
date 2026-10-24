import '../entities/match_room_entity.dart';
import '../repositories/match_room_repository.dart';
import 'pick_match_candidates_use_case.dart';

/// Match "infinito": busca o próximo lote da rodada e acrescenta à sala.
class LoadMoreMatchCandidatesUseCase {
  LoadMoreMatchCandidatesUseCase({
    required PickMatchCandidatesUseCase pickCandidates,
    required MatchRoomRepository rooms,
  })  : _pickCandidates = pickCandidates,
        _rooms = rooms;

  final PickMatchCandidatesUseCase _pickCandidates;
  final MatchRoomRepository _rooms;

  Future<void> call(MatchRoomEntity room) async {
    final fromPage = room.nextCandidatePage;
    if (fromPage == null) return;

    final batch = await _pickCandidates(
      hostId: room.hostId,
      participantIds: room.everyoneIds,
      filters: room.filters,
      startPage: fromPage,
      excludeIds: room.candidates.map((c) => c.tmdbMovieId).toSet(),
    );

    await _rooms.appendCandidates(
      roomId: room.id,
      fromPage: fromPage,
      candidates: batch.candidates,
      nextPage: batch.nextPage,
    );
  }
}
