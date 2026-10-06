import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/discover_providers.dart';
import '../widgets/discover_movie_section.dart';

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(discoverHomeProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.gold,
          onRefresh: () async {
            ref.invalidate(discoverHomeProvider);
            await ref.read(discoverHomeProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: TuliPageHeader(
                  title: 'Descubra',
                  subtitle: 'Ideias frescas para a próxima sessão da turma',
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
              homeAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: TuliFeedSkeleton(itemCount: 4),
                  ),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: TuliEmptyState(message: 'Não foi possível carregar sugestões.\n$e'),
                ),
                data: (home) => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final section = home.sections[index];
                      return DiscoverMovieSection(
                        title: section.title,
                        subtitle: section.subtitle,
                        movies: section.movies,
                      );
                    },
                    childCount: home.sections.length,
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
