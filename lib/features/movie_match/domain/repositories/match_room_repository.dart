import '../../../auth/domain/entities/user_entity.dart';
import '../entities/match_candidate_entity.dart';
import '../entities/match_filters_entity.dart';
import '../entities/match_room_entity.dart';

abstract interface class MatchRoomRepository {
  Stream<MatchRoomEntity?> watchRoom(String roomId);

  Stream<Map<String, Map<int, bool>>> watchLikes(String roomId);

  /// Cria a sala só com o host dentro e avisa cada convidado.
  Future<MatchRoomEntity> createRoom({
    required UserEntity host,
    required List<String> invitedIds,
    required MatchFiltersEntity filters,
    required List<MatchCandidateEntity> candidates,
    required int? nextCandidatePage,
  });

  /// Acrescenta mais filmes à rodada (Match "infinito").
  Future<void> appendCandidates({
    required String roomId,
    required int fromPage,
    required List<MatchCandidateEntity> candidates,
    required int? nextPage,
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
}
