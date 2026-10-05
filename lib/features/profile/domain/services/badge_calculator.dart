import '../../../feed/domain/entities/review_entity.dart';
import '../entities/badge_entity.dart';

abstract final class BadgeCalculator {
  static List<BadgeEntity> compute({
    required String userId,
    required List<ReviewEntity> reviews,
  }) {
    final userReviews = reviews.where(
      (r) => r.participants.any((p) => p.userId == userId && p.hasSubmittedRating),
    );

    final ratings = <double>[];
    var survivor = false;
    var nightOwl = false;
    var marathon = false;

    final dayCounts = <String, int>{};

    for (final review in userReviews) {
      final participant = review.participants.firstWhere((p) => p.userId == userId);
      ratings.add(participant.rating);

      if (review.groupAverageRating < 2.0) survivor = true;

      final hour = review.createdAt.hour;
      if (hour >= 2 && hour <= 5) nightOwl = true;

      final dayKey = review.createdAt.toIso8601String().substring(0, 10);
      dayCounts[dayKey] = (dayCounts[dayKey] ?? 0) + 1;
      if ((dayCounts[dayKey] ?? 0) >= 3) marathon = true;
    }

    return [
      BadgeEntity(
        id: 'survivor',
        title: 'Sobrevivente',
        emoji: '🧟',
        description: 'Assistiu filme com nota da galera abaixo de 2.',
        unlocked: survivor,
      ),
      BadgeEntity(
        id: 'night_owl',
        title: 'Corujão',
        emoji: '🦉',
        description: 'Avaliou entre 2h e 5h da manhã.',
        unlocked: nightOwl,
      ),
      BadgeEntity(
        id: 'marathon',
        title: 'Maratonista',
        emoji: '🎬',
        description: 'Registrou 3 filmes no mesmo dia.',
        unlocked: marathon,
      ),
      BadgeEntity(
        id: 'discord_lover',
        title: 'Adorador do Caos',
        emoji: '🔥',
        description: 'Participou de sessão com Selo da Discórdia.',
        unlocked: userReviews.any((r) => r.hasDiscordBadge),
      ),
    ];
  }
}
