import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/tuli_awards_entity.dart';
import '../providers/awards_providers.dart';

class TuliAwardsPage extends ConsumerStatefulWidget {
  const TuliAwardsPage({super.key});

  @override
  ConsumerState<TuliAwardsPage> createState() => _TuliAwardsPageState();
}

class _TuliAwardsPageState extends ConsumerState<TuliAwardsPage> {
  final _pageController = PageController();
  int _slide = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final year = ref.watch(awardsYearProvider);
    final awardsAsync = ref.watch(tuliAwardsProvider(year));

    return Scaffold(
      body: awardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (awards) {
          final slides = _buildSlides(context, awards);

          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: slides.length,
                onPageChanged: (index) => setState(() => _slide = index),
                itemBuilder: (_, index) => slides[index],
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                      const Spacer(),
                      Text('${_slide + 1}/${slides.length}',
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildSlides(BuildContext context, TuliAwardsEntity awards) {
    final textTheme = Theme.of(context).textTheme;

    return [
      _StorySlide(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tuli Awards', style: textTheme.displaySmall?.copyWith(color: AppColors.gold)),
            Text('${awards.year}', style: textTheme.headlineMedium),
            const SizedBox(height: 12),
            const Text('Retrospectiva da turma · deslize'),
          ],
        ),
      ),
      _StorySlide(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sessão Pipoca', style: textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text('${awards.totalMovies} filmes registrados'),
            Text('~${awards.totalHoursEstimate.toStringAsFixed(0)} horas assistidas'),
            const SizedBox(height: 8),
            Text('Crítico mais difícil: ${awards.hardestCriticName}'),
          ],
        ),
      ),
      _StorySlide(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top 5 da Galera', style: textTheme.headlineSmall),
            const SizedBox(height: 12),
            ...awards.topMovies.map(
              (movie) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    TuliPosterImage(posterPath: movie.posterPath, width: 48),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    Text('${movie.averageRating.toStringAsFixed(1)}★'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      _StorySlide(
        child: _ComicVotingSlide(year: awards.year, categories: awards.categories),
      ),
    ];
  }
}

class _StorySlide extends StatelessWidget {
  const _StorySlide({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.backgroundVignette),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
          child: child,
        ),
      ),
    );
  }
}

class _ComicVotingSlide extends ConsumerWidget {
  const _ComicVotingSlide({required this.year, required this.categories});

  final int year;
  final List<ComicCategoryEntity> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider).valueOrNull;

    return ListView(
      children: [
        Text('Votação cômica', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        ...categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TuliCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.title, style: Theme.of(context).textTheme.titleSmall),
                  Text(category.subtitle, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  TuliButton(
                    label: 'Votar',
                    size: TuliButtonSize.sm,
                    onPressed: user == null
                        ? null
                        : () => _promptVote(context, ref, category.id, user.id),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _promptVote(
    BuildContext context,
    WidgetRef ref,
    String categoryId,
    String userId,
  ) async {
    final controller = TextEditingController();
    String? choice;
    try {
      choice = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Seu voto'),
            content: TuliInputField(
              controller: controller,
              hint: 'Nome do filme ou amigo...',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Enviar'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }

    if (choice == null || choice.trim().isEmpty) return;

    await ref.read(voteComicCategoryUseCaseProvider).call(
          year: year,
          categoryId: categoryId,
          userId: userId,
          choiceText: choice,
        );

    ref.invalidate(comicVotesProvider(year));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voto registrado!')),
      );
    }
  }
}
