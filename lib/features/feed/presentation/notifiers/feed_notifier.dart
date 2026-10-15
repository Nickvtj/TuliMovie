import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/usecases/get_feed_page_use_case.dart';
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
    required ToggleReviewReactionUseCase toggleReaction,
  })  : _userId = userId,
        _isVisible = isVisible,
        _getFeedPage = getFeedPage,
        _toggleReaction = toggleReaction,
        super(const FeedState());

  static const _pageSize = 10;

  final String? _userId;

  /// Esconde posts antigos de quem o usuário deixou de seguir.
  final bool Function(ReviewEntity review) _isVisible;
  final GetFeedPageUseCase _getFeedPage;
  final ToggleReviewReactionUseCase _toggleReaction;
  FeedCursor? _cursor;

  Future<void> loadInitial() => _load(refresh: false, reset: true);

  Future<void> refresh() => _load(refresh: true, reset: true);

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isInitialLoading) return;
    await _load(refresh: false, reset: false);
  }

  Future<void> toggleReaction({
    required String reviewId,
    required String userId,
    required String reactionKey,
  }) async {
    await _toggleReaction(
      reviewId: reviewId,
      userId: userId,
      reactionKey: reactionKey,
    );
    await refresh();
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
