import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/match_candidate_entity.dart';
import '../../domain/entities/match_room_entity.dart';
import '../../domain/usecases/load_more_match_candidates_use_case.dart';

class MatchDeckState {
  const MatchDeckState({
    this.cards = const [],
    this.version = 0,
    this.isReady = false,
    this.isEnded = false,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  /// Filmes que o usuário ainda não votou, na ordem da rodada.
  final List<MatchCandidateEntity> cards;

  /// Muda quando o baralho é remontado (o swiper recomeça do primeiro card).
  final int version;
  final bool isReady;

  /// O usuário passou pelo último card do baralho atual.
  final bool isEnded;
  final bool isLoadingMore;
  final bool hasMore;

  bool get hasCards => isReady && !isEnded && cards.isNotEmpty;

  MatchDeckState copyWith({
    List<MatchCandidateEntity>? cards,
    int? version,
    bool? isReady,
    bool? isEnded,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return MatchDeckState(
      cards: cards ?? this.cards,
      version: version ?? this.version,
      isReady: isReady ?? this.isReady,
      isEnded: isEnded ?? this.isEnded,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Baralho "infinito" do swipe: pula o que o usuário já votou e busca o
/// próximo lote da sala quando faltam poucos cards.
class MatchDeckNotifier extends StateNotifier<MatchDeckState> {
  MatchDeckNotifier({
    required String userId,
    required LoadMoreMatchCandidatesUseCase loadMore,
  })  : _userId = userId,
        _loadMore = loadMore,
        super(const MatchDeckState());

  /// Pede o próximo lote cedo o bastante para chegar antes do último card.
  static const _prefetchWhenLeft = 10;

  final String _userId;
  final LoadMoreMatchCandidatesUseCase _loadMore;

  /// Votados por mim (no servidor ou neste aparelho, antes de sincronizar).
  final _seen = <int>{};
  int _position = 0;
  MatchRoomEntity? _room;

  /// Página já pedida — evita buscar o mesmo lote enquanto a sala não atualiza.
  int? _requestedPage;

  void sync(MatchRoomEntity room, Map<String, Map<int, bool>> likes) {
    _room = room;
    _seen.addAll(likes[_userId]?.keys ?? const <int>[]);
    final unseen = room.candidates.where((c) => !_seen.contains(c.tmdbMovieId)).toList();

    if (!state.isReady || state.isEnded) {
      if (state.isReady && unseen.isEmpty) {
        state = state.copyWith(hasMore: room.hasMoreCandidates);
      } else {
        _position = 0;
        state = state.copyWith(
          cards: unseen,
          version: state.version + 1,
          isReady: true,
          isEnded: unseen.isEmpty,
          hasMore: room.hasMoreCandidates,
        );
      }
    } else {
      final inDeck = state.cards.map((c) => c.tmdbMovieId).toSet();
      final fresh = unseen.where((c) => !inDeck.contains(c.tmdbMovieId));
      state = state.copyWith(cards: [...state.cards, ...fresh], hasMore: room.hasMoreCandidates);
    }
    _maybeLoadMore();
  }

  void onSwiped(MatchCandidateEntity candidate) {
    _seen.add(candidate.tmdbMovieId);
    _position++;
    _maybeLoadMore();
  }

  void onEnd() {
    state = state.copyWith(isEnded: true);
    _maybeLoadMore();
  }

  Future<void> _maybeLoadMore() async {
    final room = _room;
    final page = room?.nextCandidatePage;
    if (room == null || page == null || page == _requestedPage || state.isLoadingMore) return;

    final left = state.isEnded ? 0 : state.cards.length - _position;
    if (left > _prefetchWhenLeft) return;

    _requestedPage = page;
    state = state.copyWith(isLoadingMore: true);
    try {
      await _loadMore(room);
    } catch (_) {
      // Tenta de novo no próximo swipe.
      _requestedPage = null;
    } finally {
      if (mounted) state = state.copyWith(isLoadingMore: false);
    }
  }
}
