import 'package:equatable/equatable.dart';

import 'review_participant_entity.dart';
import '../utils/discord_badge_calculator.dart';

class ReviewEntity extends Equatable {
  const ReviewEntity({
    required this.id,
    required this.tmdbMovieId,
    required this.movieTitle,
    this.moviePosterPath,
    this.movieReleaseYear,
    required this.participants,
    required this.groupAverageRating,
    this.comment,
    required this.createdAt,
    this.reactions = const {},
  });

  final String id;
  final int tmdbMovieId;
  final String movieTitle;
  final String? moviePosterPath;
  final int? movieReleaseYear;
  final List<ReviewParticipantEntity> participants;
  final double groupAverageRating;
  final String? comment;
  final DateTime createdAt;

  /// emojiKey -> userIds
  final Map<String, List<String>> reactions;

  bool get hasDiscordBadge => DiscordBadgeCalculator.shouldShow(participants);

  double? get minParticipantRating {
    if (participants.isEmpty) return null;
    return participants.map((p) => p.rating).reduce((a, b) => a < b ? a : b);
  }

  double? get maxParticipantRating {
    if (participants.isEmpty) return null;
    return participants.map((p) => p.rating).reduce((a, b) => a > b ? a : b);
  }

  int reactionCount(String emojiKey) => reactions[emojiKey]?.length ?? 0;

  @override
  List<Object?> get props => [
        id,
        tmdbMovieId,
        movieTitle,
        moviePosterPath,
        movieReleaseYear,
        participants,
        groupAverageRating,
        comment,
        createdAt,
        reactions,
      ];
}
