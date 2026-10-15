import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';
import '../providers/tools_providers.dart';
import '../widgets/movie_roulette_widget.dart';

class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});

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
                        childAspectRatio: 0.52,
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
