import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/usecases/get_feed_page_use_case.dart';
import '../../domain/usecases/get_review_by_id_use_case.dart';
import '../../domain/usecases/toggle_review_reaction_use_case.dart';

class FeedState {
  const FeedState({
    this.reviews = const [],
    this.isInitialLoading = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.errorMessage,
  });

  final List<ReviewEntity> reviews;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasMore;
  final String? errorMessage;

  FeedState copyWith({
    List<ReviewEntity>? reviews,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FeedState(
      reviews: reviews ?? this.reviews,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier({
    required String? userId,
    required bool Function(ReviewEntity review) isVisible,
    required GetFeedPageUseCase getFeedPage,
    required GetReviewByIdUseCase getReview,
    required ToggleReviewReactionUseCase toggleReaction,
  })  : _userId = userId,
        _isVisible = isVisible,
        _getFeedPage = getFeedPage,
        _getReview = getReview,
        _toggleReaction = toggleReaction,
        super(const FeedState());

  static const _pageSize = 10;

  final String? _userId;

  /// Esconde posts antigos de quem o usuário deixou de seguir.
  final bool Function(ReviewEntity review) _isVisible;
  final GetFeedPageUseCase _getFeedPage;
  final GetReviewByIdUseCase _getReview;
  final ToggleReviewReactionUseCase _toggleReaction;
  FeedCursor? _cursor;

  Future<void> loadInitial() => _load(refresh: false, reset: true);

  Future<void> refresh() => _load(refresh: true, reset: true);

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isInitialLoading) return;
    await _load(refresh: false, reset: false);
  }

  /// Atualiza só o card na hora; se o servidor falhar, desfaz.
  Future<void> toggleReaction({
    required String reviewId,
    required String userId,
    required String reactionKey,
  }) async {
    final before = state.reviews;
    _updateReview(
      reviewId,
      (review) => review.withReactionToggled(userId: userId, reactionKey: reactionKey),
    );
    try {
      await _toggleReaction(
        reviewId: reviewId,
        userId: userId,
        reactionKey: reactionKey,
      );
    } catch (_) {
      if (mounted) state = state.copyWith(reviews: before);
    }
  }

  /// Relê um único post (ex.: contador de comentários) sem recarregar o feed.
  Future<void> reloadReview(String reviewId) async {
    try {
      final fresh = await _getReview(reviewId);
      if (fresh != null && mounted) _updateReview(reviewId, (_) => fresh);
    } catch (_) {
      // Mantém o card como está; o próximo refresh corrige.
    }
  }

  void _updateReview(String reviewId, ReviewEntity Function(ReviewEntity review) update) {
    state = state.copyWith(
      reviews: [
        for (final review in state.reviews) review.id == reviewId ? update(review) : review,
      ],
    );
  }

  Future<void> _load({required bool refresh, required bool reset}) async {
    final userId = _userId;
    if (userId == null) {
      state = state.copyWith(
        isInitialLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        reviews: const [],
        hasMore: false,
      );
      return;
    }

    if (reset) _cursor = null;

    state = state.copyWith(
      isInitialLoading: !refresh && reset && state.reviews.isEmpty,
      isRefreshing: refresh,
      isLoadingMore: !refresh && !reset,
      clearError: true,
    );

    try {
      final page = await _getFeedPage(
        userId: userId,
        limit: _pageSize,
        cursor: reset ? null : _cursor,
      );
      _cursor = page.nextCursor;

      final visible = page.reviews.where(_isVisible).toList();
      final merged = reset ? visible : [...state.reviews, ...visible];

      state = state.copyWith(
        reviews: merged,
        hasMore: page.hasMore,
        isInitialLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isInitialLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        errorMessage: 'Não foi possível carregar o feed.',
      );
    }
  }
}
