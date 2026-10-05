import '../../domain/repositories/awards_repository.dart';
import '../datasources/awards_firestore_data_source.dart';

class AwardsRepositoryImpl implements AwardsRepository {
  AwardsRepositoryImpl(this._dataSource);

  final AwardsFirestoreDataSource _dataSource;

  @override
  Future<void> voteComicCategory({
    required int year,
    required String categoryId,
    required String userId,
    required String choiceText,
  }) {
    return _dataSource.voteComicCategory(
      year: year,
      categoryId: categoryId,
      userId: userId,
      choiceText: choiceText,
    );
  }

  @override
  Future<Map<String, String>> fetchVotesForYear(int year) {
    return _dataSource.fetchVotesForYear(year);
  }
}
