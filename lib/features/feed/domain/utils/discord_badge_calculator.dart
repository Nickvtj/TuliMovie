import '../entities/review_participant_entity.dart';

/// Selo da Discórdia — spread de notas acima do limiar (doc: ~1.5–2.0).
abstract final class DiscordBadgeCalculator {
  static const double spreadThreshold = 1.5;

  static bool shouldShow(List<ReviewParticipantEntity> participants) {
    if (participants.length < 2) return false;
    final ratings = participants.map((p) => p.rating);
    final min = ratings.reduce((a, b) => a < b ? a : b);
    final max = ratings.reduce((a, b) => a > b ? a : b);
    return (max - min) >= spreadThreshold;
  }
}
