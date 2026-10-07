import '../../../../core/utils/iterable_extensions.dart';
import '../../../feed/domain/entities/review_entity.dart';
import '../entities/profile_dashboard_entity.dart';

abstract final class Top4Calculator {
  static List<TopMovieSlotEntity> fromReviews({
    required String userId,
    required List<ReviewEntity> reviews,
  }) {
    final slots = <TopMovieSlotEntity>[];

    for (final review in reviews) {
      final participant = review.participants.where((p) => p.userId == userId).firstOrNull;
      if (participant == null || !participant.hasSubmittedRating) continue;

      slots.add(
        TopMovieSlotEntity(
          tmdbMovieId: review.tmdbMovieId,
          title: review.movieTitle,
          posterPath: review.moviePosterPath,
          userRating: participant.rating,
        ),
      );
    }

    slots.sort((a, b) => b.userRating.compareTo(a.userRating));

    final unique = <int, TopMovieSlotEntity>{};
    for (final slot in slots) {
      unique.putIfAbsent(slot.tmdbMovieId, () => slot);
      if (unique.length >= 4) break;
    }

    return unique.values.toList();
  }
}
