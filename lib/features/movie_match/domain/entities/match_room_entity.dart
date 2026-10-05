import 'package:equatable/equatable.dart';

import 'match_candidate_entity.dart';
import 'match_filters_entity.dart';

enum MatchRoomStatus { waiting, swiping, matched, closed }

class MatchRoomEntity extends Equatable {
  const MatchRoomEntity({
    required this.id,
    required this.hostId,
    required this.participantIds,
    required this.filters,
    required this.candidates,
    required this.status,
    this.matchedMovieId,
    required this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String hostId;
  final List<String> participantIds;
  final MatchFiltersEntity filters;
  final List<MatchCandidateEntity> candidates;
  final MatchRoomStatus status;
  final int? matchedMovieId;
  final DateTime createdAt;
  final DateTime? expiresAt;

  String get shortCode => id.length >= 6 ? id.substring(0, 6).toUpperCase() : id.toUpperCase();

  bool get isHostReadyForSwipe => status == MatchRoomStatus.swiping || status == MatchRoomStatus.matched;

  @override
  List<Object?> get props => [
        id,
        hostId,
        participantIds,
        filters,
        candidates,
        status,
        matchedMovieId,
        createdAt,
        expiresAt,
      ];
}
