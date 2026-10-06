import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/match_room_entity.dart';
import '../../domain/utils/match_consensus_calculator.dart';
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

  @override
  Widget build(BuildContext context) {
    ref.listen(matchLikesStreamProvider(widget.roomId), (previous, next) {
      if (!next.hasValue) return;
      final room = ref.read(matchRoomStreamProvider(widget.roomId)).valueOrNull;
      if (room == null) return;
      _checkMatch(room, next.requireValue);
    });

    final roomAsync = ref.watch(matchRoomStreamProvider(widget.roomId));
    final likesAsync = ref.watch(matchLikesStreamProvider(widget.roomId));
    final user = ref.watch(authSessionProvider).valueOrNull;

    return roomAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (room) {
        if (room == null) {
          return const Scaffold(body: Center(child: Text('Sala não encontrada.')));
        }

        if (room.status == MatchRoomStatus.matched && room.matchedMovieId != null) {
          final movie = room.candidates.firstWhere(
            (c) => c.tmdbMovieId == room.matchedMovieId,
            orElse: () => room.candidates.first,
          );
          return Scaffold(
            appBar: AppBar(title: const Text('Match!')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'A turma quer ver:\n${movie.title}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          );
        }

        final candidates = room.candidates;
        if (candidates.isEmpty) {
          return const Scaffold(body: Center(child: Text('Sem filmes na rodada.')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Swipe · ${room.shortCode}'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Text(
                    '${room.participantIds.length} na sala',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                MatchActiveFiltersBar(filters: room.filters),
                const SizedBox(height: 8),
                Expanded(
                  child: CardSwiper(
                    controller: _swiperController,
                    cardsCount: candidates.length,
                    numberOfCardsDisplayed: candidates.length >= 2 ? 2 : 1,
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    backCardOffset: const Offset(0, 18),
                    scale: 0.94,
                    cardBuilder: (context, index, horizontal, vertical) {
                      return MatchSwipeCard(candidate: candidates[index]);
                    },
                    onSwipe: (previousIndex, currentIndex, direction) {
                      if (previousIndex == null || user == null) return true;
                      final candidate = candidates[previousIndex];
                      final liked = direction == CardSwiperDirection.right;

                      ref.read(matchRoomRepositoryProvider).submitSwipe(
                            roomId: widget.roomId,
                            userId: user.id,
                            tmdbMovieId: candidate.tmdbMovieId,
                            liked: liked,
                          );
                      return true;
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SwipeHint(color: AppColors.neonRed, label: 'Nope ←', icon: Icons.close),
                    _SwipeHint(color: AppColors.gold, label: 'Match →', icon: Icons.favorite),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({required this.color, required this.label, required this.icon});

  final Color color;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
