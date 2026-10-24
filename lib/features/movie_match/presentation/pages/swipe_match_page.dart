import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/match_candidate_entity.dart';
import '../../domain/entities/match_room_entity.dart';
import '../../domain/utils/match_consensus_calculator.dart';
import '../notifiers/match_deck_notifier.dart';
import '../providers/match_providers.dart';
import '../widgets/match_active_filters_bar.dart';
import '../widgets/match_celebration_dialog.dart';
import '../widgets/match_swipe_card.dart';

class SwipeMatchPage extends ConsumerStatefulWidget {
  const SwipeMatchPage({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<SwipeMatchPage> createState() => _SwipeMatchPageState();
}

class _SwipeMatchPageState extends ConsumerState<SwipeMatchPage> {
  final _swiperController = CardSwiperController();
  bool _celebrationShown = false;

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  void _checkMatch(MatchRoomEntity room, Map<String, Map<int, bool>> likes) {
    if (_celebrationShown || room.status == MatchRoomStatus.matched) return;

    final movieId = MatchConsensusCalculator.findMatch(
      participantIds: room.participantIds,
      likesByUser: likes,
      candidateMovieIds: room.candidates.map((c) => c.tmdbMovieId).toList(),
    );

    if (movieId == null) return;

    final movie = room.candidates.firstWhere((c) => c.tmdbMovieId == movieId);
    _celebrationShown = true;

    ref.read(matchRoomRepositoryProvider).markMatched(
          roomId: room.id,
          tmdbMovieId: movieId,
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showMatchCelebrationDialog(context, movie: movie);
    });
  }

  /// Quem da sala (fora eu) já curtiu [movieId].
  static List<String> _likedBy(
    MatchRoomEntity room,
    Map<String, Map<int, bool>> likes,
    String? me,
    int movieId,
  ) {
    return [
      for (final userId in room.participantIds)
        if (userId != me && likes[userId]?[movieId] == true) userId,
    ];
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(matchLikesStreamProvider(widget.roomId), (previous, next) {
      if (!next.hasValue) return;
      final room = ref.read(matchRoomStreamProvider(widget.roomId)).valueOrNull;
      if (room == null) return;
      _checkMatch(room, next.requireValue);
    });

    final roomAsync = ref.watch(matchRoomStreamProvider(widget.roomId));

    return roomAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (room) {
        if (room == null) {
          return const Scaffold(body: Center(child: Text('Sala não encontrada.')));
        }

        if (room.status == MatchRoomStatus.matched && room.matchedMovieId != null) {
          return _MatchedView(room: room);
        }

        return _buildSwipe(room);
      },
    );
  }

  Widget _buildSwipe(MatchRoomEntity room) {
    final deck = ref.watch(matchDeckProvider(widget.roomId));
    final deckNotifier = ref.read(matchDeckProvider(widget.roomId).notifier);
    final likes = ref.watch(matchLikesStreamProvider(widget.roomId)).valueOrNull ?? const {};
    final user = ref.watch(authSessionProvider).valueOrNull;
    final canSwipe = deck.hasCards && user != null;

    bool onSwipe(MatchCandidateEntity candidate, CardSwiperDirection direction) {
      if (user == null) return false;
      ref.read(matchRoomRepositoryProvider).submitSwipe(
            roomId: widget.roomId,
            userId: user.id,
            tmdbMovieId: candidate.tmdbMovieId,
            liked: direction == CardSwiperDirection.right,
          );
      deckNotifier.onSwiped(candidate);
      return true;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TuliScreenHeader(
              mode: TuliScreenHeaderMode.stacked,
              title: 'Match',
              subtitle: 'Sala ${room.shortCode} · ${room.participantIds.length} na sala',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: MatchActiveFiltersBar(filters: room.filters),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: canSwipe
                    ? CardSwiper(
                        key: ValueKey(deck.version),
                        controller: _swiperController,
                        cardsCount: deck.cards.length,
                        numberOfCardsDisplayed: deck.cards.length >= 2 ? 2 : 1,
                        isLoop: false,
                        allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
                          horizontal: true,
                        ),
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        backCardOffset: const Offset(0, 22),
                        scale: 0.92,
                        cardBuilder: (context, index, horizontal, vertical) {
                          final candidate = deck.cards[index];
                          return MatchSwipeCard(
                            candidate: candidate,
                            likedByIds: _likedBy(room, likes, user.id, candidate.tmdbMovieId),
                            dragPercent: horizontal,
                          );
                        },
                        onSwipe: (previousIndex, currentIndex, direction) =>
                            onSwipe(deck.cards[previousIndex], direction),
                        onEnd: deckNotifier.onEnd,
                      )
                    : _DeckStatus(deck: deck),
              ),
            ),
            _SwipeActions(
              onNope: canSwipe ? () => _swiperController.swipe(CardSwiperDirection.left) : null,
              onLike: canSwipe ? () => _swiperController.swipe(CardSwiperDirection.right) : null,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// Sem cards: carregando, buscando mais ou rodada esgotada.
class _DeckStatus extends StatelessWidget {
  const _DeckStatus({required this.deck});

  final MatchDeckState deck;

  @override
  Widget build(BuildContext context) {
    if (!deck.isReady || deck.isLoadingMore || deck.hasMore) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              deck.isReady ? 'Buscando mais filmes…' : 'Embaralhando os filmes…',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }
    return const TuliEmptyState(
      message: 'Você viu todos os filmes desta rodada.\n'
          'Espere a galera votar ou crie uma sala com outros filtros.',
      icon: Icons.movie_filter_outlined,
    );
  }
}

class _SwipeActions extends StatelessWidget {
  const _SwipeActions({required this.onNope, required this.onLike});

  final VoidCallback? onNope;
  final VoidCallback? onLike;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundAction(
          icon: Icons.close_rounded,
          color: AppColors.neonRed,
          size: 60,
          tooltip: 'Não quero',
          onPressed: onNope,
        ),
        const SizedBox(width: AppSpacing.xxl + AppSpacing.sm),
        _RoundAction(
          icon: Icons.favorite_rounded,
          color: AppColors.gold,
          size: 72,
          tooltip: 'Quero ver',
          onPressed: onLike,
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.color,
    required this.size,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final double size;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AnimatedOpacity(
        opacity: onPressed == null ? 0.35 : 1,
        duration: AppDurations.fast,
        child: Material(
          color: AppColors.surfaceElevated,
          shape: CircleBorder(side: BorderSide(color: color.withValues(alpha: 0.6), width: 1.5)),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: color, size: size * 0.46),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchedView extends StatelessWidget {
  const _MatchedView({required this.room});

  final MatchRoomEntity room;

  @override
  Widget build(BuildContext context) {
    final movie = room.candidates.firstWhere(
      (c) => c.tmdbMovieId == room.matchedMovieId,
      orElse: () => room.candidates.first,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TuliScreenHeader(
              mode: TuliScreenHeaderMode.stacked,
              title: 'Match!',
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  0,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                ),
                child: Column(
                  children: [
                    Text(
                      'Vocês querem ver',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.gold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(child: MatchSwipeCard(candidate: movie)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
