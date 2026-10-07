import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/tuli_http_client.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../groups/presentation/providers/group_providers.dart';
import '../../../movies/domain/constants/tmdb_genres.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../groups/presentation/pages/group_hub_page.dart';
import '../../../tools/presentation/pages/watchlist_page.dart';
import '../../../tools/presentation/providers/tools_providers.dart';
import '../../../tools/presentation/widgets/watchlist_group_picker_sheet.dart';
import '../providers/discover_providers.dart';
import '../widgets/discover_chips_bar_widget.dart';
import '../widgets/discover_filter_bottom_sheet.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  static const _pageSize = 20;
  static const _snackDuration = Duration(seconds: 3);

  final PagingController<int, MovieEntity> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  @override
  void dispose() {
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    _pagingController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {SnackBarAction? action}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: _snackDuration,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  Future<void> _fetchPage(int pageKey) async {
    final user = ref.read(authSessionProvider).valueOrNull;
    if (user == null) {
      _pagingController.error = 'Faça login para ver sugestões.';
      return;
    }

    try {
      final filters = ref.read(discoverFiltersProvider);
      final useCase = ref.read(getDiscoverMoviesUseCaseProvider);
      final result = await useCase(
        userId: user.id,
        filters: filters,
        page: pageKey,
      );

      final isLastPage = !result.hasMore || result.movies.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(result.movies);
      } else {
        _pagingController.appendPage(result.movies, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _refreshFeed() {
    sl<TuliHttpClient>().clearCache();
    _pagingController.refresh();
    ref.invalidate(userWatchedMovieIdsProvider);
  }

  Future<void> _onMarkWatched(MovieEntity movie) async {
    final user = ref.read(authSessionProvider).valueOrNull;
    if (user == null) return;

    try {
      await ref.read(markMovieWatchedUseCaseProvider).call(
            userId: user.id,
            tmdbMovieId: movie.id,
            title: movie.title,
            posterPath: movie.posterPath,
          );
      if (!mounted) return;
      ref.invalidate(userWatchedMovieIdsProvider);
      ref.invalidate(profileDashboardProvider);
      _showSnack('${movie.title} marcado como assistido.');
      _refreshFeed();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Não foi possível marcar como assistido. Verifique o Firebase.');
    }
  }

  Future<void> _onToggleWatchlist(MovieEntity movie) async {
    final groups = ref.read(userGroupsProvider).valueOrNull ?? [];
    if (groups.isEmpty) {
      _showSnack('Entre em uma turma em Minha turma para usar a watchlist.');
      return;
    }

    final before = ref.read(watchlistGroupsForMovieProvider(movie.id));

    try {
      final after = await WatchlistGroupPickerSheet.show(
        context,
        groups: groups,
        title: 'Watchlist por turma',
        initialSelectedIds: before,
        applyLabel: 'Salvar',
      );
      if (after == null || !mounted) return;

      final toggle = ref.read(toggleWatchlistItemUseCaseProvider);
      for (final group in groups) {
        final was = before.contains(group.id);
        final now = after.contains(group.id);
        if (was == now) continue;
        await toggle.call(
          groupId: group.id,
          tmdbMovieId: movie.id,
          title: movie.title,
          posterPath: movie.posterPath,
          isCurrentlyInList: was,
        );
      }

      if (!mounted) return;
      if (after.isEmpty) {
        _showSnack('${movie.title} removido das watchlists selecionadas.');
      } else {
        _showSnack(
          '${movie.title} atualizado na watchlist.',
          action: SnackBarAction(
            label: 'Ver lista',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const WatchlistPage()),
              );
            },
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack('Não foi possível atualizar a watchlist.');
    }
  }

  Future<void> _spinLuck() async {
    final user = ref.read(authSessionProvider).valueOrNull;
    if (user == null) return;

    final filters = ref.read(discoverFiltersProvider);
    final useCase = ref.read(getDiscoverMoviesUseCaseProvider);
    final page = Random().nextInt(5) + 1;
    final result = await useCase(userId: user.id, filters: filters, page: page);
    if (result.movies.isEmpty || !mounted) return;

    final movie = result.movies[Random().nextInt(result.movies.length)];
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Girar a sorte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TuliPosterImage(posterPath: movie.posterPath, width: 120),
            const SizedBox(height: 12),
            Text(movie.title, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MovieDetailsPage(movieId: movie.id),
                ),
              );
            },
            child: const Text('Ver detalhes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(discoverFiltersProvider);
    final streamLabel = streamingLabelForFilters(filters);
    final watchedIds = ref.watch(userWatchedMovieIdsProvider).valueOrNull ?? {};
    final watchlistIds = ref.watch(watchlistMovieIdsProvider);
    final watchlistCount = ref.watch(watchlistMovieIdsProvider).length;

    ref.listen(discoverFiltersProvider, (previous, next) {
      if (previous != next) _refreshFeed();
    });

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TuliGlowFab(
          icon: Icons.casino_outlined,
          label: 'Girar a sorte',
          onPressed: _spinLuck,
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.gold,
          onRefresh: () async => _refreshFeed(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: TuliSectionHeader(
                  title: 'Descubra',
                  subtitle: 'Ideias frescas para a próxima sessão da turma',
                  trailingActions: [
                    TuliIconButtonCircle(
                      icon: Icons.groups_rounded,
                      tooltip: 'Turma',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const GroupHubPage()),
                        );
                      },
                    ),
                  ],
                  bookmarkCount: watchlistCount,
                  onBookmarkTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const WatchlistPage()),
                    );
                  },
                  onFilterTap: () async {
                    final updated = await DiscoverFilterBottomSheet.show(
                      context,
                      initial: filters,
                    );
                    if (updated != null) {
                      ref.read(discoverFiltersProvider.notifier).state = updated;
                    }
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: DiscoverChipsBarWidget(
                    selectedGenreId: filters.primaryGenreId,
                    onGenreSelected: (genreId) {
                      ref.read(discoverFiltersProvider.notifier).state = genreId == null
                          ? filters.copyWith(clearPrimaryGenre: true)
                          : filters.copyWith(primaryGenreId: genreId);
                    },
                  ),
                ),
              ),
              if (!EnvConfig.hasTmdbApiKey)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Configure TMDB_API_KEY para carregar sugestões.',
                      style: TextStyle(color: AppColors.gold),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: PagedSliverGrid(
                  pagingController: _pagingController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.52,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  builderDelegate: PagedChildBuilderDelegate<MovieEntity>(
                    itemBuilder: (context, movie, index) {
                      final year = movie.releaseDate != null && movie.releaseDate!.length >= 4
                          ? movie.releaseDate!.substring(0, 4)
                          : null;
                      final watched = watchedIds.contains(movie.id);
                      final inWatchlist = watchlistIds.contains(movie.id);

                      final genreLabel = movie.genreIds.isNotEmpty
                          ? TmdbGenres.labelFor(movie.genreIds.first)
                          : null;

                      return MovieCardWidget(
                        title: movie.title,
                        posterPath: movie.posterPath,
                        year: year,
                        genreLabel: genreLabel,
                        voteAverage: movie.voteAverage,
                        streamingProviderLabel: streamLabel,
                        isWatched: watched,
                        isInWatchlist: inWatchlist,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => MovieDetailsPage(movieId: movie.id),
                            ),
                          );
                        },
                        onMarkWatched: watched ? null : () => _onMarkWatched(movie),
                        onAddWatchlist: () => _onToggleWatchlist(movie),
                      );
                    },
                    firstPageErrorIndicatorBuilder: (_) => TuliEmptyState(
                      message: 'Não foi possível carregar a grade.\n${_pagingController.error}',
                    ),
                    newPageErrorIndicatorBuilder: (_) => const TuliEmptyState(
                      message: 'Erro ao carregar mais filmes.',
                    ),
                    noItemsFoundIndicatorBuilder: (_) => const TuliEmptyState(
                      message: 'Nenhum filme encontrado com esses filtros.',
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        ),
      ),
    );
  }
}
