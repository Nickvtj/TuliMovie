import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Buscar', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  TuliInputField(
                    label: 'Filmes',
                    hint: 'Digite o nome do filme...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    onChanged: notifier.onQueryChanged,
                  ),
                ],
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
      return Center(
        child: Text(
          'Comece digitando para buscar no TMDB',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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
      return const Center(child: Text('Nenhum filme encontrado.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: search.results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final movie = search.results[index];
        return TuliCard(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MovieDetailsPage(movieId: movie.id),
              ),
            );
          },
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              TuliPosterImage(posterPath: movie.posterPath, width: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, style: Theme.of(context).textTheme.titleMedium),
                    if (movie.releaseDate != null && movie.releaseDate!.length >= 4)
                      Text(
                        movie.releaseDate!.substring(0, 4),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        );
      },
    );
  }
}
