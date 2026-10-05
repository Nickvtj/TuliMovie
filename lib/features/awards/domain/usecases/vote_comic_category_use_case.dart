import '../repositories/awards_repository.dart';

class VoteComicCategoryUseCase {
  VoteComicCategoryUseCase(this._repository);

  final AwardsRepository _repository;

  Future<void> call({
    required int year,
    required String categoryId,
    required String userId,
    required String choiceText,
  }) {
    return _repository.voteComicCategory(
      year: year,
      categoryId: categoryId,
      userId: userId,
      choiceText: choiceText.trim(),
    );
  }
}
