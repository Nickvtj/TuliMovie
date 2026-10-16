import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/feed/domain/entities/review_entity.dart';

void main() {
  final review = ReviewEntity(
    id: 'r1',
    tmdbMovieId: 1,
    movieTitle: 'Filme',
    participants: const [],
    groupAverageRating: 0,
    createdAt: DateTime(2026),
    reactions: const {
      'sleep': ['bia'],
    },
  );

  test('adiciona a reação de quem ainda não reagiu', () {
    final updated = review.withReactionToggled(userId: 'ana', reactionKey: 'sleep');
    expect(updated.reactions['sleep'], ['bia', 'ana']);
  });

  test('remove a reação de quem já reagiu e não altera o original', () {
    final updated = review.withReactionToggled(userId: 'bia', reactionKey: 'sleep');
    expect(updated.reactions['sleep'], isEmpty);
    expect(review.reactions['sleep'], ['bia']);
  });
}
