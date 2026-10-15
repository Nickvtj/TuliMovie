import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/feed/data/mappers/review_mapper.dart';
import 'package:tulimovie/features/feed/data/models/review_model.dart';

void main() {
  final review = ReviewModel(
    id: 'r1',
    tmdbMovieId: 603,
    movieTitle: 'Matrix',
    participants: const [],
    groupAverageRating: 4.5,
    createdAt: DateTime(2026, 10, 15),
    authorId: 'ana',
    audienceIds: const ['ana', 'bia'],
  );

  test('grava autor e audiência', () {
    final json = review.toJson();

    expect(json['authorId'], 'ana');
    expect(json['audienceIds'], ['ana', 'bia']);
  });

  test('lê autor e audiência de volta e expõe o autor na entidade', () {
    final parsed = ReviewModel.fromJson({...review.toJson(), 'id': 'r1'});

    expect(parsed.authorId, 'ana');
    expect(parsed.audienceIds, ['ana', 'bia']);
    expect(ReviewMapper.toEntity(parsed).authorId, 'ana');
  });
}
