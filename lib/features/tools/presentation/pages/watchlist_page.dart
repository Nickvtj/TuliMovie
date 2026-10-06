import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';
import '../providers/tools_providers.dart';

class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quero ver')),
      body: watchlist.when(
        loading: () => const Center(child: TuliFeedSkeleton(itemCount: 4)),
        error: (_, __) => const TuliEmptyState(
          message: 'Não foi possível carregar a watchlist do grupo.',
        ),
        data: (items) {
          if (items.isEmpty) {
            return const TuliEmptyState(
              message:
                  'Nenhum filme na lista ainda.\nUse o bookmark no Descubra para salvar o que querem assistir.',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.52,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
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
          );
        },
      ),
    );
  }
}
