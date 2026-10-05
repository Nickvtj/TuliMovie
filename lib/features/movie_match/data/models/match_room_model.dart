import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/match_candidate_entity.dart';
import '../../domain/entities/match_filters_entity.dart';
import '../../domain/entities/match_room_entity.dart';

class MatchRoomModel {
  const MatchRoomModel({
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

  factory MatchRoomModel.fromJson(Map<String, dynamic> json) {
    final candidatesRaw = json['candidates'] as List<dynamic>? ?? [];
    final candidates = candidatesRaw
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => MatchCandidateEntity(
            tmdbMovieId: (item['tmdbMovieId'] as num).toInt(),
            title: item['title'] as String? ?? '',
            posterPath: item['posterPath'] as String?,
            overview: item['overview'] as String?,
            releaseYear: (item['releaseYear'] as num?)?.toInt(),
          ),
        )
        .toList();

    final filtersMap = json['filters'] as Map<String, dynamic>? ?? {};

    return MatchRoomModel(
      id: json['id'] as String? ?? '',
      hostId: json['hostId'] as String? ?? '',
      participantIds: (json['participantIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      filters: MatchFiltersEntity(
        withWatchProviderId: (filtersMap['withWatchProviderId'] as num?)?.toInt(),
        maxRuntimeMinutes: (filtersMap['maxRuntimeMinutes'] as num?)?.toInt(),
        genreId: (filtersMap['genreId'] as num?)?.toInt(),
      ),
      candidates: candidates,
      status: MatchRoomStatus.values.byName(json['status'] as String? ?? 'waiting'),
      matchedMovieId: (json['matchedMovieId'] as num?)?.toInt(),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      expiresAt: _parseDate(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostId': hostId,
      'participantIds': participantIds,
      'filters': {
        if (filters.withWatchProviderId != null)
          'withWatchProviderId': filters.withWatchProviderId,
        if (filters.maxRuntimeMinutes != null)
          'maxRuntimeMinutes': filters.maxRuntimeMinutes,
        if (filters.genreId != null) 'genreId': filters.genreId,
      },
      'candidates': candidates
          .map(
            (c) => {
              'tmdbMovieId': c.tmdbMovieId,
              'title': c.title,
              if (c.posterPath != null) 'posterPath': c.posterPath,
              if (c.overview != null) 'overview': c.overview,
              if (c.releaseYear != null) 'releaseYear': c.releaseYear,
            },
          )
          .toList(),
      'status': status.name,
      if (matchedMovieId != null) 'matchedMovieId': matchedMovieId,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(
        expiresAt ?? createdAt.add(const Duration(hours: 6)),
      ),
    };
  }

  MatchRoomEntity toEntity() {
    return MatchRoomEntity(
      id: id,
      hostId: hostId,
      participantIds: participantIds,
      filters: filters,
      candidates: candidates,
      status: status,
      matchedMovieId: matchedMovieId,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
