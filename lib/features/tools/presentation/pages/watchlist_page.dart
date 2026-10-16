import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../discover/presentation/providers/discover_providers.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';
import '../../domain/entities/watchlist_item_entity.dart';
import '../providers/tools_providers.dart';
import '../widgets/movie_roulette_widget.dart';

class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});

  Future<void> _remove(BuildContext context, WidgetRef ref, WatchlistItemEntity item) async {
    final userId = ref.read(authSessionProvider).valueOrNull?.id;
    if (userId == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(toggleWatchlistItemUseCaseProvider).call(
            userId: userId,
            tmdbMovieId: item.tmdbMovieId,
            title: item.title,
            posterPath: item.posterPath,
            isCurrentlyInList: true,
          );
      messenger.showSnackBar(SnackBar(content: Text('${item.title} removido da watchlist.')));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível remover. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistItemsProvider);

    return Scaffold(
      body: SafeArea(
        child: watchlist.when(
          loading: () => const Center(child: TuliFeedSkeleton(itemCount: 4)),
          error: (_, __) => const TuliEmptyState(
            message: 'Não foi possível carregar sua watchlist.',
          ),
          data: (items) {
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: TuliScreenHeader(
                    mode: TuliScreenHeaderMode.stacked,
                    title: 'Minha watchlist',
                  ),
                ),
                if (items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: TuliEmptyState(
                      message: 'Nenhum filme salvo.\nUse o bookmark no Descubra para adicionar.',
                    ),
                  )
                else ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: MovieRouletteWidget(compact: true),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        // Pôster 2:3 + título + botão "Remover".
                        childAspectRatio: 0.48,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = items[index];
                          return MovieCardWidget(
                            title: item.title,
                            posterPath: item.posterPath,
                            isInWatchlist: true,
                            onRemove: () => _remove(context, ref, item),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => MovieDetailsPage(movieId: item.tmdbMovieId),
                                ),
                              );
                            },
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
