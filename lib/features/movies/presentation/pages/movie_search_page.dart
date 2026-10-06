import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../notifiers/movie_search_notifier.dart';
import '../providers/movie_providers.dart';
import 'movie_details_page.dart';

class MovieSearchPage extends ConsumerWidget {
  const MovieSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(movieSearchNotifierProvider);
    final notifier = ref.read(movieSearchNotifierProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TuliPageHeader(
              title: 'Avaliar filme',
              subtitle: 'Encontre no TMDB e compartilhe com a turma',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TuliInputField(
                label: 'Buscar filme',
                hint: 'Digite o nome do filme...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                onChanged: notifier.onQueryChanged,
              ),
            ),
            if (!EnvConfig.hasTmdbApiKey)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Configure TMDB_API_KEY ao iniciar (scripts/run_web.cmd).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gold),
                ),
              ),
            Expanded(child: _ResultsBody(search: search)),
          ],
        ),
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({required this.search});

  final MovieSearchState search;

  @override
  Widget build(BuildContext context) {
    if (search.query.trim().length < 2) {
      return const TuliEmptyState(
        message: 'Digite pelo menos 2 letras para buscar no catálogo TMDB.',
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

    if (search.results.isEmpty) {
      return const TuliEmptyState(message: 'Nenhum filme encontrado para essa busca.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: search.results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final movie = search.results[index];
        final year = movie.releaseDate != null && movie.releaseDate!.length >= 4
            ? movie.releaseDate!.substring(0, 4)
            : null;
        return TuliMovieListTile(
          title: movie.title,
          posterPath: movie.posterPath,
          subtitle: year,
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
