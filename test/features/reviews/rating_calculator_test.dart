import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/reviews/domain/entities/rating_answer_set.dart';
import 'package:tulimovie/features/reviews/domain/entities/rating_calculator.dart';
import 'package:tulimovie/features/reviews/domain/entities/rating_dimension.dart';

void main() {
  test('média individual das 5 perguntas', () {
    final answers = RatingAnswerSet.fromMap({
      RatingDimension.plot: 5,
      RatingDimension.acting: 5,
      RatingDimension.visuals: 5,
      RatingDimension.soundtrack: 5,
      RatingDimension.fun: 3,
    });

    expect(RatingCalculator.individualAverage(answers), 4.6);
  });

  test('média consolidada da sessão', () {
    final result = RatingCalculator.consolidate({
      'u1': RatingAnswerSet.fromMap({
        RatingDimension.plot: 4,
        RatingDimension.acting: 4,
        RatingDimension.visuals: 4,
        RatingDimension.soundtrack: 4,
        RatingDimension.fun: 4,
      }),
      'u2': RatingAnswerSet.fromMap({
        RatingDimension.plot: 2,
        RatingDimension.acting: 2,
        RatingDimension.visuals: 2,
        RatingDimension.soundtrack: 2,
        RatingDimension.fun: 2,
      }),
    });

    expect(result.individualAverages['u1'], 4);
    expect(result.individualAverages['u2'], 2);
    expect(result.sessionAverage, 3);
  });
}
