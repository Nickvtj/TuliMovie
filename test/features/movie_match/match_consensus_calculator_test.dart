import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/movie_match/domain/utils/match_consensus_calculator.dart';

void main() {
  test('detecta match unânime em grupo', () {
    final result = MatchConsensusCalculator.findMatch(
      participantIds: ['a', 'b'],
      candidateMovieIds: [1, 2],
      likesByUser: {
        'a': {1: true, 2: false},
        'b': {1: true, 2: true},
      },
    );

    expect(result, 1);
  });

  test('solo: match no primeiro like à direita', () {
    final result = MatchConsensusCalculator.findMatch(
      participantIds: ['solo'],
      candidateMovieIds: [10, 20],
      likesByUser: {
        'solo': {10: false, 20: true},
      },
    );

    expect(result, 20);
  });

  test('solo: negação não gera match', () {
    final result = MatchConsensusCalculator.findMatch(
      participantIds: ['solo'],
      candidateMovieIds: [10, 20],
      likesByUser: {
        'solo': {10: false, 20: false},
      },
    );

    expect(result, isNull);
  });
}
