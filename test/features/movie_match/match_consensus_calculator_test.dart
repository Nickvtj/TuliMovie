import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/movie_match/domain/utils/match_consensus_calculator.dart';

void main() {
  test('detecta match unânime', () {
    final result = MatchConsensusCalculator.findUnanimousMatch(
      participantIds: ['a', 'b'],
      candidateMovieIds: [1, 2],
      likesByUser: {
        'a': {1: true, 2: false},
        'b': {1: true, 2: true},
      },
    );

    expect(result, 1);
  });
}
