import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_participant_entity.dart';
import '../models/review_model.dart';

abstract final class ReviewMapper {
  static ReviewEntity toEntity(ReviewModel model) {
    return ReviewEntity(
      id: model.id,
      tmdbMovieId: model.tmdbMovieId,
      movieTitle: model.movieTitle,
      moviePosterPath: model.moviePosterPath,
      movieReleaseYear: model.movieReleaseYear,
      participants: model.participants.map(_participant).toList(),
      groupAverageRating: model.groupAverageRating,
      comment: model.comment,
      createdAt: model.createdAt,
      reactions: model.reactions,
      containsSpoiler: model.containsSpoiler,
      groupIds: model.resolvedGroupIds,
    );
  }

  static List<ReviewEntity> toEntityList(List<ReviewModel> models) =>
      models.map(toEntity).toList();

  static ReviewParticipantEntity _participant(ReviewParticipantModel model) {
    return ReviewParticipantEntity(
      userId: model.userId,
      displayName: model.displayName,
      rating: model.rating,
      photoUrl: model.photoUrl,
      hasSubmittedRating: model.hasSubmittedRating,
    );
  }
}
