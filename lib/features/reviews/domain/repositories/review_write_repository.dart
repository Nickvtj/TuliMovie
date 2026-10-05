import '../../../auth/domain/entities/user_entity.dart';
import '../../../feed/domain/entities/review_entity.dart';
import '../../../movies/domain/entities/movie_details_entity.dart';
import '../entities/rating_answer_set.dart';

abstract interface class ReviewWriteRepository {
  Future<ReviewEntity> createReview({
    required MovieDetailsEntity movie,
    required UserEntity author,
    required List<UserEntity> taggedFriends,
    required double authorIndividualRating,
    required double groupAverageRating,
    required String comment,
    required bool containsSpoiler,
    required RatingAnswerSet authorAnswers,
  });
}
