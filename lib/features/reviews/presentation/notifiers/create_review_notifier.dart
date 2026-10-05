import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../movies/domain/entities/movie_details_entity.dart';
import '../../domain/entities/create_review_draft.dart';
import '../../domain/entities/rating_answer_set.dart';
import '../../domain/entities/rating_dimension.dart';
import '../../domain/usecases/create_review_use_case.dart';
import '../../domain/usecases/list_group_members_use_case.dart';

class CreateReviewState {
  const CreateReviewState({
    required this.draft,
    this.step = 0,
    this.members = const [],
    this.isLoadingMembers = true,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final CreateReviewDraft draft;
  final int step;
  final List<UserEntity> members;
  final bool isLoadingMembers;
  final bool isSubmitting;
  final String? errorMessage;

  static const maxStep = 2;

  bool get canGoNext {
    if (step == 0) return true;
    if (step == 1) return draft.answerSet != null;
    return draft.comment.trim().isNotEmpty || true; // comment optional
  }

  CreateReviewState copyWith({
    CreateReviewDraft? draft,
    int? step,
    List<UserEntity>? members,
    bool? isLoadingMembers,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CreateReviewState(
      draft: draft ?? this.draft,
      step: step ?? this.step,
      members: members ?? this.members,
      isLoadingMembers: isLoadingMembers ?? this.isLoadingMembers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class CreateReviewNotifier extends StateNotifier<CreateReviewState> {
  CreateReviewNotifier({
    required int tmdbMovieId,
    required ListGroupMembersUseCase listMembers,
    required CreateReviewUseCase createReview,
    required MovieDetailsEntity movie,
    required UserEntity author,
  })  : _listMembers = listMembers,
        _createReview = createReview,
        _movie = movie,
        _author = author,
        super(
          CreateReviewState(
            draft: CreateReviewDraft(tmdbMovieId: tmdbMovieId),
          ),
        ) {
    _loadMembers();
  }

  final ListGroupMembersUseCase _listMembers;
  final CreateReviewUseCase _createReview;
  final MovieDetailsEntity _movie;
  final UserEntity _author;

  Future<void> _loadMembers() async {
    try {
      final members = await _listMembers(excludeUserId: _author.id);
      state = state.copyWith(members: members, isLoadingMembers: false);
    } catch (_) {
      state = state.copyWith(
        isLoadingMembers: false,
        errorMessage: 'Não foi possível carregar a galera.',
      );
    }
  }

  void toggleFriend(UserEntity friend) {
    final selected = List<UserEntity>.from(state.draft.selectedFriends);
    final exists = selected.any((user) => user.id == friend.id);
    if (exists) {
      selected.removeWhere((user) => user.id == friend.id);
    } else {
      selected.add(friend);
    }
    state = state.copyWith(
      draft: state.draft.copyWith(selectedFriends: selected),
      clearError: true,
    );
  }

  void setDimensionRating(RatingDimension dimension, double value) {
    final answers = Map<RatingDimension, double>.from(state.draft.answers);
    answers[dimension] = value;
    state = state.copyWith(
      draft: state.draft.copyWith(answers: answers),
      clearError: true,
    );
  }

  void setComment(String value) {
    state = state.copyWith(
      draft: state.draft.copyWith(comment: value),
      clearError: true,
    );
  }

  void setContainsSpoiler(bool value) {
    state = state.copyWith(
      draft: state.draft.copyWith(containsSpoiler: value),
      clearError: true,
    );
  }

  void nextStep() {
    if (state.step >= CreateReviewState.maxStep) return;
    if (state.step == 1 && state.draft.answerSet == null) {
      state = state.copyWith(errorMessage: 'Complete as 5 perguntas antes de continuar.');
      return;
    }
    state = state.copyWith(step: state.step + 1, clearError: true);
  }

  void previousStep() {
    if (state.step <= 0) return;
    state = state.copyWith(step: state.step - 1, clearError: true);
  }

  Future<bool> submit() async {
    final answerSet = state.draft.answerSet;
    if (answerSet == null) {
      state = state.copyWith(errorMessage: 'Responda todas as perguntas.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      answerSet.validate();
      await _createReview(
        CreateReviewParams(
          movie: _movie,
          author: _author,
          selectedFriends: state.draft.selectedFriends,
          answers: answerSet,
          comment: state.draft.comment,
          containsSpoiler: state.draft.containsSpoiler,
        ),
      );
      state = state.copyWith(isSubmitting: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Não foi possível publicar a avaliação.',
      );
      return false;
    }
  }
}
