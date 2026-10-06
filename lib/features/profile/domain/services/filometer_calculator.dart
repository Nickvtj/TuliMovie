import '../../../feed/domain/entities/review_entity.dart';

/// Estima horas assistidas (2h por filme registrado do usuário).
abstract final class FilometerCalculator {
  static const defaultRuntimeHours = 2.0;

  static double hoursForUser({
    required String userId,
    required List<ReviewEntity> reviews,
    Set<int> personalWatchedMovieIds = const {},
  }) {
    final fromReviews = reviews
        .where((review) {
          return review.participants.any((p) => p.userId == userId && p.hasSubmittedRating);
        })
        .map((r) => r.tmdbMovieId)
        .toSet();

    final uniqueCount = {...fromReviews, ...personalWatchedMovieIds}.length;

    return double.parse((uniqueCount * defaultRuntimeHours).toStringAsFixed(1));
  }
}
