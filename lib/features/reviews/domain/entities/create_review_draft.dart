import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';
import 'rating_answer_set.dart';
import 'rating_dimension.dart';

class CreateReviewDraft extends Equatable {
  const CreateReviewDraft({
    required this.tmdbMovieId,
    this.selectedFriends = const [],
    this.answers = const {},
    this.comment = '',
    this.containsSpoiler = false,
    this.selectedGroupIds = const [],
  });

  final int tmdbMovieId;
  final List<String> selectedGroupIds;
  final List<UserEntity> selectedFriends;
  final Map<RatingDimension, double> answers;
  final String comment;
  final bool containsSpoiler;

  CreateReviewDraft copyWith({
    List<UserEntity>? selectedFriends,
    List<String>? selectedGroupIds,
    Map<RatingDimension, double>? answers,
    String? comment,
    bool? containsSpoiler,
  }) {
    return CreateReviewDraft(
      tmdbMovieId: tmdbMovieId,
      selectedFriends: selectedFriends ?? this.selectedFriends,
      selectedGroupIds: selectedGroupIds ?? this.selectedGroupIds,
      answers: answers ?? this.answers,
      comment: comment ?? this.comment,
      containsSpoiler: containsSpoiler ?? this.containsSpoiler,
    );
  }

  RatingAnswerSet? get answerSet {
    if (answers.length != RatingDimension.all.length) return null;
    return RatingAnswerSet.fromMap(answers);
  }

  @override
  List<Object?> get props => [
        tmdbMovieId,
        selectedFriends,
        answers,
        comment,
        containsSpoiler,
        selectedGroupIds,
      ];
}
