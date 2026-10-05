import '../entities/review_participant_entity.dart';

/// Selo da Discórdia — spread de notas acima do limiar (doc: ~1.5–2.0).
abstract final class DiscordBadgeCalculator {
  static const double spreadThreshold = 1.5;

  static bool shouldShow(List<ReviewParticipantEntity> participants) {
    final ratings = participants
        .where((p) => p.countsForSessionAverage)
        .map((p) => p.rating)
        .toList();
    if (ratings.length < 2) return false;
    final min = ratings.reduce((a, b) => a < b ? a : b);
    final max = ratings.reduce((a, b) => a > b ? a : b);
    return (max - min) >= spreadThreshold;
  }
}
