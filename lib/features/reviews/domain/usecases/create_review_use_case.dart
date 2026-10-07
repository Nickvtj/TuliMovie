import '../../../auth/domain/entities/user_entity.dart';
import '../../../feed/domain/entities/review_entity.dart';
import '../../../movies/domain/entities/movie_details_entity.dart';
import '../entities/rating_answer_set.dart';
import '../entities/rating_calculator.dart';
import '../repositories/review_write_repository.dart';

class CreateReviewParams {
  const CreateReviewParams({
    required this.movie,
    required this.author,
    required this.selectedFriends,
    required this.answers,
    required this.comment,
    required this.containsSpoiler,
    required this.groupIds,
  });

  final MovieDetailsEntity movie;
  final UserEntity author;
  final List<UserEntity> selectedFriends;
  final RatingAnswerSet answers;
  final String comment;
  final bool containsSpoiler;
  final List<String> groupIds;
}

class CreateReviewUseCase {
  CreateReviewUseCase(this._repository);

  final ReviewWriteRepository _repository;

  Future<ReviewEntity> call(CreateReviewParams params) {
    final authorRating = RatingCalculator.individualAverage(params.answers);

    // Amigos marcados entram na sessão; nota individual só do autor neste fluxo.
    // Média do grupo = média dos participantes que já possuem nota (>0).
    final ratedParticipants = <String, double>{
      params.author.id: authorRating,
    };

    final sessionAverage = RatingCalculator.sessionAverage(ratedParticipants.values);

    return _repository.createReview(
      movie: params.movie,
      author: params.author,
      taggedFriends: params.selectedFriends,
      authorIndividualRating: authorRating,
      groupAverageRating: sessionAverage,
      comment: params.comment.trim(),
      containsSpoiler: params.containsSpoiler,
      authorAnswers: params.answers,
      groupIds: params.groupIds,
    );
  }
}
