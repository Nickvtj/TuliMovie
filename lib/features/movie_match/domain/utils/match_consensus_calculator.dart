/// Detecta unanimidade: todos curtiram o mesmo filme.
abstract final class MatchConsensusCalculator {
  static int? findUnanimousMatch({
    required List<String> participantIds,
    required Map<String, Map<int, bool>> likesByUser,
    required List<int> candidateMovieIds,
  }) {
    if (participantIds.isEmpty) return null;

    for (final movieId in candidateMovieIds) {
      final unanimous = participantIds.every((userId) {
        return likesByUser[userId]?[movieId] == true;
      });
      if (unanimous) return movieId;
    }
    return null;
  }
}
