import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/match_candidate_entity.dart';
import '../../domain/entities/match_filters_entity.dart';
import '../../domain/entities/match_room_entity.dart';

class MatchRoomModel {
  const MatchRoomModel({
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
  final List<String> participantIds;
  final List<String> invitedIds;
  final MatchFiltersEntity filters;
  final List<MatchCandidateEntity> candidates;
  final MatchRoomStatus status;
  final int? matchedMovieId;
  final int? nextCandidatePage;
  final DateTime createdAt;
  final DateTime? expiresAt;

  factory MatchRoomModel.fromJson(Map<String, dynamic> json) {
    final candidatesRaw = json['candidates'] as List<dynamic>? ?? [];
    final candidates = candidatesRaw
        .whereType<Map<String, dynamic>>()
        .map(candidateFromJson)
        .toList();

    final filtersMap = json['filters'] as Map<String, dynamic>? ?? {};

    return MatchRoomModel(
      id: json['id'] as String? ?? '',
      hostId: json['hostId'] as String? ?? '',
      participantIds: (json['participantIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      invitedIds: (json['invitedIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      filters: _parseFilters(filtersMap),
      candidates: candidates,
      status: MatchRoomStatus.values.byName(json['status'] as String? ?? 'waiting'),
      matchedMovieId: (json['matchedMovieId'] as num?)?.toInt(),
      nextCandidatePage: (json['nextCandidatePage'] as num?)?.toInt(),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      expiresAt: _parseDate(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostId': hostId,
      'participantIds': participantIds,
      'invitedIds': invitedIds,
      'filters': _filtersToJson(filters),
      'candidates': candidates.map(candidateToJson).toList(),
      'status': status.name,
      if (matchedMovieId != null) 'matchedMovieId': matchedMovieId,
      if (nextCandidatePage != null) 'nextCandidatePage': nextCandidatePage,
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
      invitedIds: invitedIds,
      filters: filters,
      candidates: candidates,
      status: status,
      matchedMovieId: matchedMovieId,
      nextCandidatePage: nextCandidatePage,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  static MatchCandidateEntity candidateFromJson(Map<String, dynamic> item) {
    return MatchCandidateEntity(
      tmdbMovieId: (item['tmdbMovieId'] as num).toInt(),
      title: item['title'] as String? ?? '',
      posterPath: item['posterPath'] as String?,
      overview: item['overview'] as String?,
      releaseYear: (item['releaseYear'] as num?)?.toInt(),
    );
  }

  static Map<String, dynamic> candidateToJson(MatchCandidateEntity c) => {
        'tmdbMovieId': c.tmdbMovieId,
        'title': c.title,
        if (c.posterPath != null) 'posterPath': c.posterPath,
        if (c.overview != null) 'overview': c.overview,
        if (c.releaseYear != null) 'releaseYear': c.releaseYear,
      };

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static MatchFiltersEntity _parseFilters(Map<String, dynamic> map) {
    final providerIds = <int>[];
    final legacyProvider = (map['withWatchProviderId'] as num?)?.toInt();
    if (legacyProvider != null) providerIds.add(legacyProvider);
    if (map['withWatchProviderIds'] is List) {
      for (final value in map['withWatchProviderIds'] as List) {
        if (value is num) providerIds.add(value.toInt());
      }
    }

    final genreIds = <int>[];
    final legacyGenre = (map['genreId'] as num?)?.toInt();
    if (legacyGenre != null) genreIds.add(legacyGenre);
    if (map['genreIds'] is List) {
      for (final value in map['genreIds'] as List) {
        if (value is num) genreIds.add(value.toInt());
      }
    }

    return MatchFiltersEntity(
      withWatchProviderIds: providerIds,
      maxRuntimeMinutes: (map['maxRuntimeMinutes'] as num?)?.toInt(),
      genreIds: genreIds,
      releaseYearFrom: (map['releaseYearFrom'] as num?)?.toInt(),
      releaseYearTo: (map['releaseYearTo'] as num?)?.toInt(),
      includeWatchlist: map['includeWatchlist'] == true,
    );
  }

  static Map<String, dynamic> _filtersToJson(MatchFiltersEntity filters) {
    return {
      if (filters.withWatchProviderIds.isNotEmpty)
        'withWatchProviderIds': filters.withWatchProviderIds,
      if (filters.maxRuntimeMinutes != null)
        'maxRuntimeMinutes': filters.maxRuntimeMinutes,
      if (filters.genreIds.isNotEmpty) 'genreIds': filters.genreIds,
      if (filters.releaseYearFrom != null) 'releaseYearFrom': filters.releaseYearFrom,
      if (filters.releaseYearTo != null) 'releaseYearTo': filters.releaseYearTo,
      if (filters.includeWatchlist) 'includeWatchlist': true,
    };
  }
}
