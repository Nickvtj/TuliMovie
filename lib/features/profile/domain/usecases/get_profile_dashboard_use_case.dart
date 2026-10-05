import '../../../auth/domain/entities/user_entity.dart';
import '../../../feed/domain/entities/review_entity.dart';
import '../entities/profile_dashboard_entity.dart';
import '../repositories/profile_repository.dart';
import '../services/badge_calculator.dart';
import '../services/cinephile_label_calculator.dart';
import '../services/filometer_calculator.dart';
import '../services/top4_calculator.dart';

class GetProfileDashboardUseCase {
  GetProfileDashboardUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileDashboardEntity> call(UserEntity user) async {
    final reviews = await _repository.fetchReviewsForUser(user.id);

    final ratings = <double>[];
    for (final review in reviews) {
      for (final participant in review.participants) {
        if (participant.userId == user.id && participant.hasSubmittedRating) {
          ratings.add(participant.rating);
        }
      }
    }

    final avg = ratings.isEmpty
        ? 3.0
        : ratings.reduce((a, b) => a + b) / ratings.length;

    return ProfileDashboardEntity(
      displayName: user.displayName,
      cinephileLabel: CinephileLabelCalculator.labelForAverage(avg),
      filometerHours: FilometerCalculator.hoursForUser(userId: user.id, reviews: reviews),
      top4: Top4Calculator.fromReviews(userId: user.id, reviews: reviews),
      badges: BadgeCalculator.compute(userId: user.id, reviews: reviews),
      recentReviews: reviews.take(12).toList(),
    );
  }
}
