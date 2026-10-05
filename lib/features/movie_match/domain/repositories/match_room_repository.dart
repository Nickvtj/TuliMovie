import '../entities/match_candidate_entity.dart';
import '../entities/match_filters_entity.dart';
import '../entities/match_room_entity.dart';

abstract interface class MatchRoomRepository {
  Stream<MatchRoomEntity?> watchRoom(String roomId);

  Stream<Map<String, Map<int, bool>>> watchLikes(String roomId);

  Future<MatchRoomEntity> createRoom({
    required String hostId,
    required List<String> participantIds,
    required MatchFiltersEntity filters,
    required List<MatchCandidateEntity> candidates,
  });

  Future<void> joinRoom({required String roomId, required String userId});

  Future<void> startSwiping(String roomId);

  Future<void> submitSwipe({
    required String roomId,
    required String userId,
    required int tmdbMovieId,
    required bool liked,
  });

  Future<void> markMatched({
    required String roomId,
    required int tmdbMovieId,
  });

  Future<MatchRoomEntity?> findRoomByShortCode(String shortCode);
}
