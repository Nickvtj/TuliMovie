import 'package:equatable/equatable.dart';

import '../../../feed/domain/entities/review_entity.dart';
import 'badge_entity.dart';

class TopMovieSlotEntity extends Equatable {
  const TopMovieSlotEntity({
    required this.tmdbMovieId,
    required this.title,
    this.posterPath,
    required this.userRating,
  });

  final int tmdbMovieId;
  final String title;
  final String? posterPath;
  final double userRating;

  @override
  List<Object?> get props => [tmdbMovieId, title, posterPath, userRating];
}

class ProfileDashboardEntity extends Equatable {
  const ProfileDashboardEntity({
    required this.displayName,
    required this.cinephileLabel,
    required this.filometerHours,
    required this.top4,
    required this.badges,
    required this.recentReviews,
    required this.totalReviews,
  });

  final String displayName;
  final String cinephileLabel;
  final double filometerHours;
  final List<TopMovieSlotEntity> top4;
  final List<BadgeEntity> badges;
  final List<ReviewEntity> recentReviews;
  final int totalReviews;

  @override
  List<Object?> get props => [
        displayName,
        cinephileLabel,
        filometerHours,
        top4,
        badges,
        recentReviews,
        totalReviews,
      ];
}
