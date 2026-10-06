/// Detecta match: solo = primeiro like; grupo = unanimidade com like explícito.
abstract final class MatchConsensusCalculator {
  static int? findMatch({
    required List<String> participantIds,
    required Map<String, Map<int, bool>> likesByUser,
    required List<int> candidateMovieIds,
  }) {
    if (participantIds.isEmpty) return null;

    if (participantIds.length == 1) {
      return _findSoloMatch(
        userId: participantIds.first,
        likesByUser: likesByUser,
        candidateMovieIds: candidateMovieIds,
      );
    }

    return _findGroupUnanimousMatch(
      participantIds: participantIds,
      likesByUser: likesByUser,
      candidateMovieIds: candidateMovieIds,
    );
  }

  @Deprecated('Use findMatch')
  static int? findUnanimousMatch({
    required List<String> participantIds,
    required Map<String, Map<int, bool>> likesByUser,
    required List<int> candidateMovieIds,
  }) {
    return findMatch(
      participantIds: participantIds,
      likesByUser: likesByUser,
      candidateMovieIds: candidateMovieIds,
    );
  }

  static int? _findSoloMatch({
    required String userId,
    required Map<String, Map<int, bool>> likesByUser,
    required List<int> candidateMovieIds,
  }) {
    final votes = likesByUser[userId] ?? {};
    for (final movieId in candidateMovieIds) {
      if (votes[movieId] == true) return movieId;
    }
    return null;
  }

  static int? _findGroupUnanimousMatch({
    required List<String> participantIds,
    required Map<String, Map<int, bool>> likesByUser,
    required List<int> candidateMovieIds,
  }) {
    for (final movieId in candidateMovieIds) {
      final unanimous = participantIds.every((userId) {
        return likesByUser[userId]?[movieId] == true;
      });
      if (unanimous) return movieId;
    }
    return null;
  }
}
