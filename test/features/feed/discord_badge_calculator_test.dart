import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/feed/domain/entities/review_participant_entity.dart';
import 'package:tulimovie/features/feed/domain/utils/discord_badge_calculator.dart';

void main() {
  test('Selo da Discórdia ativa com spread >= 1.5', () {
    const participants = [
      ReviewParticipantEntity(userId: '1', displayName: 'A', rating: 5),
      ReviewParticipantEntity(userId: '2', displayName: 'B', rating: 3),
    ];

    expect(DiscordBadgeCalculator.shouldShow(participants), isTrue);
  });
}
