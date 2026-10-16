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

enum _SearchSort {
  relevance('Relevância'),
  year('Mais recentes'),
  rating('Melhor nota');

  const _SearchSort(this.label);

  final String label;
}

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
    final hasResults =
        search.query.trim().length >= 2 && !search.isLoading && search.errorMessage == null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TuliScreenHeader(
              mode: TuliScreenHeaderMode.root,
              title: 'Avaliar',
              subtitle: 'Encontre o filme que você assistiu e dê sua nota',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _SearchField(
                controller: _queryController,
                onChanged: notifier.onQueryChanged,
                onClear: () {
                  _queryController.clear();
                  notifier.onQueryChanged('');
                },
              ),
            ),
            if (!EnvConfig.hasTmdbApiKey)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                child: Text(
                  'Configure TMDB_API_KEY ao iniciar (scripts/run_web.cmd).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gold),
                ),
              ),
            if (hasResults && results.isNotEmpty)
              _SortBar(
                resultCount: results.length,
                selected: _sort,
                onSelected: (sort) => setState(() => _sort = sort),
              ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: _ResultsBody(search: search, results: results, isUpcoming: _isUpcoming)),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: AppShape.borderRadiusPill,
      borderSide: const BorderSide(color: AppColors.borderElevated),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Buscar filme, saga ou diretor...',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpar',
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                onPressed: onClear,
              ),
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class _SortBar extends StatelessWidget {
  const _SortBar({
    required this.resultCount,
    required this.selected,
    required this.onSelected,
  });

  final int resultCount;
  final _SearchSort selected;
  final ValueChanged<_SearchSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              resultCount == 1 ? '1 filme encontrado' : '$resultCount filmes encontrados',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: _SearchSort.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final sort = _SearchSort.values[index];
                return TuliFilterChip(
                  label: sort.label,
                  selected: sort == selected,
                  onSelected: () => onSelected(sort),
                );
              },
            ),
          ),
        ],
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
        message: 'Qual filme você viu?\nDigite pelo menos 2 letras para buscar.',
        icon: Icons.movie_filter_outlined,
      );
    }

    if (search.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: TuliFeedSkeleton(itemCount: 5),
      );
    }

    if (search.errorMessage != null) {
      return TuliEmptyState(message: search.errorMessage!, icon: Icons.error_outline_rounded);
    }

    if (results.isEmpty) {
      return const TuliEmptyState(
        message: 'Nenhum filme encontrado.\nTente outro título ou o nome original.',
        icon: Icons.search_off_rounded,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, 96),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final movie = results[index];
        final year = movie.releaseDate != null && movie.releaseDate!.length >= 4
            ? movie.releaseDate!.substring(0, 4)
            : null;
        final genre = movie.genreIds.isNotEmpty ? TmdbGenres.labelFor(movie.genreIds.first) : null;

        return TuliMovieListTile(
          title: movie.title,
          posterPath: movie.posterPath,
          year: year,
          genreLabel: genre,
          voteAverage: movie.voteAverage,
          overview: movie.overview,
          isUpcoming: isUpcoming(movie),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => MovieDetailsPage(movieId: movie.id)),
            );
          },
        );
      },
    );
  }
}
