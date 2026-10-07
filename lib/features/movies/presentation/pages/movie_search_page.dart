import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/constants/tmdb_genres.dart';
import '../../domain/entities/movie_entity.dart';
import '../notifiers/movie_search_notifier.dart';
import '../providers/movie_providers.dart';
import 'movie_details_page.dart';

enum _SearchSort { relevance, year, rating }

class MovieSearchPage extends ConsumerStatefulWidget {
  const MovieSearchPage({super.key});

  @override
  ConsumerState<MovieSearchPage> createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends ConsumerState<MovieSearchPage> {
  final _queryController = TextEditingController();
  _SearchSort _sort = _SearchSort.relevance;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<MovieEntity> _sorted(List<MovieEntity> movies) {
    final list = List<MovieEntity>.from(movies);
    switch (_sort) {
      case _SearchSort.year:
        list.sort((a, b) => (b.releaseDate ?? '').compareTo(a.releaseDate ?? ''));
      case _SearchSort.rating:
        list.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
      case _SearchSort.relevance:
        break;
    }
    return list;
  }

  String _sortLabel(_SearchSort sort) {
    switch (sort) {
      case _SearchSort.relevance:
        return 'relevância';
      case _SearchSort.year:
        return 'ano';
      case _SearchSort.rating:
        return 'nota';
    }
  }

  void _cycleSort() {
    setState(() {
      _sort = switch (_sort) {
        _SearchSort.relevance => _SearchSort.year,
        _SearchSort.year => _SearchSort.rating,
        _SearchSort.rating => _SearchSort.relevance,
      };
    });
  }

  bool _isUpcoming(MovieEntity movie) {
    final date = movie.releaseDate;
    if (date == null || date.length < 4) return false;
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return false;
    return parsed.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(movieSearchNotifierProvider);
    final notifier = ref.read(movieSearchNotifierProvider.notifier);
    final results = _sorted(search.results);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TuliScreenHeader(
              mode: TuliScreenHeaderMode.root,
              title: 'Avaliar',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: TextField(
                controller: _queryController,
                onChanged: notifier.onQueryChanged,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Buscar filme, saga ou diretor...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                  suffixIcon: _queryController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                          onPressed: () {
                            _queryController.clear();
                            notifier.onQueryChanged('');
                            setState(() {});
                          },
                        ),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: AppShape.borderRadiusMd,
                    borderSide: const BorderSide(color: AppColors.borderElevated),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppShape.borderRadiusMd,
                    borderSide: const BorderSide(color: AppColors.borderElevated),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppShape.borderRadiusMd,
                    borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (!EnvConfig.hasTmdbApiKey)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Configure TMDB_API_KEY ao iniciar (scripts/run_web.cmd).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gold),
                ),
              ),
            if (search.query.trim().length >= 2 && !search.isLoading && search.errorMessage == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'RESULTADOS (${results.length})',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _cycleSort,
                      icon: const Icon(Icons.swap_vert_rounded, size: 18),
                      label: Text('Ordenado por ${_sortLabel(_sort)}'),
                    ),
                  ],
                ),
              ),
            Expanded(child: _ResultsBody(search: search, results: results, isUpcoming: _isUpcoming)),
          ],
        ),
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({
    required this.search,
    required this.results,
    required this.isUpcoming,
  });

  final MovieSearchState search;
  final List<MovieEntity> results;
  final bool Function(MovieEntity) isUpcoming;

  @override
  Widget build(BuildContext context) {
    if (search.query.trim().length < 2) {
      return const TuliEmptyState(
        message: 'Digite pelo menos 2 letras para buscar no catálogo',
        icon: Icons.add_circle_outline,
      );
    }

    if (search.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: TuliFeedSkeleton(itemCount: 5),
      );
    }

    if (search.errorMessage != null) {
      return Center(child: Text(search.errorMessage!));
    }

    if (results.isEmpty) {
      return const TuliEmptyState(message: 'Nenhum filme encontrado para essa busca.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final movie = results[index];
        final year = movie.releaseDate != null && movie.releaseDate!.length >= 4
            ? movie.releaseDate!.substring(0, 4)
            : null;
        final genre = movie.genreIds.isNotEmpty ? TmdbGenres.labelFor(movie.genreIds.first) : null;
        final upcoming = isUpcoming(movie);

        return TuliMovieListTile(
          title: movie.title,
          posterPath: movie.posterPath,
          year: year,
          genreLabel: genre,
          voteAverage: movie.voteAverage,
          isUpcoming: upcoming,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MovieDetailsPage(movieId: movie.id),
              ),
            );
          },
        );
      },
    );
  }
}
