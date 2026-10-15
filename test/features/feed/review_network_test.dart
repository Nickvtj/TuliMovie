import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/feed/domain/entities/review_entity.dart';

ReviewEntity _byAuthor(String authorId) => ReviewEntity(
      id: 'r-$authorId',
      tmdbMovieId: 1,
      movieTitle: 'Filme',
      participants: const [],
      groupAverageRating: 0,
      createdAt: DateTime(2026),
      authorId: authorId,
    );

void main() {
  const following = {'ana'};

  test('post próprio e de quem sigo são da minha rede', () {
    expect(_byAuthor('me').isFromNetworkOf('me', following), isTrue);
    expect(_byAuthor('ana').isFromNetworkOf('me', following), isTrue);
  });

  test('post de quem não sigo fica de fora', () {
    expect(_byAuthor('carlos').isFromNetworkOf('me', following), isFalse);
  });
}
