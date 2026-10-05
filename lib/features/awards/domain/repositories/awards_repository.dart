abstract interface class AwardsRepository {
  Future<void> voteComicCategory({
    required int year,
    required String categoryId,
    required String userId,
    required String choiceText,
  });

  Future<Map<String, String>> fetchVotesForYear(int year);
}
