import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/providers/group_providers.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';
import '../providers/tools_providers.dart';
import '../widgets/movie_roulette_widget.dart';

class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistItemsProvider);
    final groupsAsync = ref.watch(userGroupsProvider);
    final selectedGroupId = ref.watch(watchlistViewGroupIdProvider);

    return Scaffold(
      body: SafeArea(
        child: groupsAsync.when(
          loading: () => const Center(child: TuliFeedSkeleton(itemCount: 4)),
          error: (_, __) => const TuliEmptyState(message: 'Erro ao carregar turmas.'),
          data: (groups) {
            if (groups.isEmpty) {
              return const TuliEmptyState(
                message: 'Entre em uma turma para usar a watchlist compartilhada.',
              );
            }

            if (selectedGroupId == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(watchlistViewGroupIdProvider.notifier).state = groups.first.id;
              });
            }

            final activeId = selectedGroupId ?? groups.first.id;

            return watchlist.when(
              loading: () => const Center(child: TuliFeedSkeleton(itemCount: 4)),
              error: (_, __) => const TuliEmptyState(
                message: 'Não foi possível carregar a watchlist do grupo.',
              ),
              data: (items) {
                return CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                      child: TuliScreenHeader(
                        mode: TuliScreenHeaderMode.stacked,
                        title: 'Watchlist',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _WatchlistGroupTabs(
                        groups: groups,
                        selectedGroupId: activeId,
                        onSelected: (id) {
                          ref.read(watchlistViewGroupIdProvider.notifier).state = id;
                        },
                      ),
                    ),
                    if (items.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: TuliEmptyState(
                          message:
                              'Nenhum filme nesta turma.\nUse o bookmark no Descubra e escolha a turma.',
                        ),
                      )
                    else ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.md,
                            AppSpacing.lg,
                            AppSpacing.lg,
                          ),
                          child: const MovieRouletteWidget(compact: true),
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
            );
          },
        ),
      ),
    );
  }
}

class _WatchlistGroupTabs extends StatelessWidget {
  const _WatchlistGroupTabs({
    required this.groups,
    required this.selectedGroupId,
    required this.onSelected,
  });

  final List<GroupEntity> groups;
  final String selectedGroupId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final group in groups)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: TuliFilterChip(
                  label: group.name,
                  selected: selectedGroupId == group.id,
                  onSelected: () => onSelected(group.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
