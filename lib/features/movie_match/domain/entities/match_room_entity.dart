import 'package:equatable/equatable.dart';

import 'match_candidate_entity.dart';
import 'match_filters_entity.dart';

enum MatchRoomStatus { waiting, swiping, matched, closed }

class MatchRoomEntity extends Equatable {
  const MatchRoomEntity({
    required this.id,
    required this.hostId,
    required this.participantIds,
    this.invitedIds = const [],
    required this.filters,
    required this.candidates,
    required this.status,
    this.matchedMovieId,
    this.nextCandidatePage,
    required this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String hostId;

  /// Quem já entrou na sala (inclui o host).
  final List<String> participantIds;

  /// Quem o host convidou — pode entrar pela notificação.
  final List<String> invitedIds;
  final MatchFiltersEntity filters;
  final List<MatchCandidateEntity> candidates;
  final MatchRoomStatus status;
  final int? matchedMovieId;

  /// Próxima página do TMDB para buscar mais filmes; `null` quando acabaram.
  final int? nextCandidatePage;
  final DateTime createdAt;
  final DateTime? expiresAt;

  bool get hasMoreCandidates => nextCandidatePage != null;

  /// Host, convidados e quem já entrou — todos têm o "já vi" excluído da rodada.
  Set<String> get everyoneIds => {hostId, ...invitedIds, ...participantIds};

  String get shortCode => id.length >= 6 ? id.substring(0, 6).toUpperCase() : id.toUpperCase();

  bool get isHostReadyForSwipe => status == MatchRoomStatus.swiping || status == MatchRoomStatus.matched;

  /// Convidado que ainda não entrou.
  bool canJoin(String userId) =>
      invitedIds.contains(userId) && !participantIds.contains(userId);

  @override
  List<Object?> get props => [
        id,
        hostId,
        participantIds,
        invitedIds,
        filters,
        candidates,
        status,
        matchedMovieId,
        nextCandidatePage,
        createdAt,
        expiresAt,
      ];
}
