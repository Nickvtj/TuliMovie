import '../../../auth/domain/entities/user_entity.dart';
import '../../../feed/data/datasources/review_firestore_data_source.dart';
import '../../../feed/data/mappers/review_mapper.dart';
import '../../../feed/data/models/review_model.dart';
import '../../../feed/domain/entities/review_entity.dart';
import '../../../movies/domain/entities/movie_details_entity.dart';
import '../../domain/entities/rating_answer_set.dart';
import '../../domain/entities/rating_dimension.dart';
import '../../domain/repositories/review_write_repository.dart';

class ReviewWriteRepositoryImpl implements ReviewWriteRepository {
  ReviewWriteRepositoryImpl(this._reviews);

  final ReviewFirestoreDataSource _reviews;

  @override
  Future<ReviewEntity> createReview({
    required MovieDetailsEntity movie,
    required UserEntity author,
    required List<UserEntity> taggedFriends,
    required double authorIndividualRating,
    required double groupAverageRating,
    required String comment,
    required bool containsSpoiler,
    required RatingAnswerSet authorAnswers,
    required List<String> groupIds,
  }) async {
    final releaseYear = _parseYear(movie.movie.releaseDate);

    final participants = <ReviewParticipantModel>[
      ReviewParticipantModel(
        userId: author.id,
        displayName: author.displayName,
        rating: authorIndividualRating,
        photoUrl: author.photoUrl,
        hasSubmittedRating: true,
      ),
      ...taggedFriends.map(
        (friend) => ReviewParticipantModel(
          userId: friend.id,
          displayName: friend.displayName,
          rating: 0,
          photoUrl: friend.photoUrl,
          hasSubmittedRating: false,
        ),
      ),
    ];

    final resolvedGroups = groupIds.where((id) => id.isNotEmpty).toList();

    final model = ReviewModel(
      id: '',
      tmdbMovieId: movie.movie.id,
      movieTitle: movie.movie.title,
      moviePosterPath: movie.movie.posterPath,
      movieReleaseYear: releaseYear,
      participants: participants,
      groupAverageRating: groupAverageRating,
      comment: comment.isEmpty ? null : comment,
      createdAt: DateTime.now(),
      containsSpoiler: containsSpoiler,
      authorAnswers: {
        for (final dimension in RatingDimension.all)
          dimension.name: authorAnswers.answers[dimension]!,
      },
      groupId: resolvedGroups.isNotEmpty ? resolvedGroups.first : null,
      groupIds: resolvedGroups,
    );

    final saved = await _reviews.createReview(model);
    return ReviewMapper.toEntity(saved);
  }

  int? _parseYear(String? releaseDate) {
    if (releaseDate == null || releaseDate.length < 4) return null;
    return int.tryParse(releaseDate.substring(0, 4));
  }
}
