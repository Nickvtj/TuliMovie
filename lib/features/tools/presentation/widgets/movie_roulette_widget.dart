import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/watchlist_item_entity.dart';
import '../providers/tools_providers.dart';

class MovieRouletteWidget extends ConsumerStatefulWidget {
  const MovieRouletteWidget({super.key});

  @override
  ConsumerState<MovieRouletteWidget> createState() => _MovieRouletteWidgetState();
}

class _MovieRouletteWidgetState extends ConsumerState<MovieRouletteWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  WatchlistItemEntity? _result;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin(List<WatchlistItemEntity> items) async {
    if (items.isEmpty) return;
    setState(() => _result = null);

    final random = Random();
    final winner = items[random.nextInt(items.length)];

    _controller
      ..reset()
      ..forward();

    await Future<void>.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    setState(() => _result = winner);
    _showResultModal(winner);
  }

  void _showResultModal(WatchlistItemEntity item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: TuliCard(
            variant: TuliCardVariant.goldAccent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Roleta sorteou', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                TuliPosterImage(posterPath: item.posterPath, width: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final watchlist = ref.watch(watchlistItemsProvider);

    return watchlist.when(
      loading: () => const TuliShimmerLoader(
        child: TuliShimmerBox(width: double.infinity, height: 80),
      ),
      error: (_, __) => const Text('Watchlist indisponível.'),
      data: (items) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final turns = Curves.easeOutCubic.transform(_controller.value) * 6;
                return Transform.rotate(
                  angle: turns * 2 * pi,
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.goldShimmer,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.25),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.casino, color: Color(0xFF1A1400), size: 34),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TuliButton(
              label: items.isEmpty ? 'Watchlist vazia' : 'Girar roleta (${items.length})',
              icon: Icons.shuffle,
              expand: true,
              onPressed: items.isEmpty ? null : () => _spin(items),
            ),
            if (_result != null) ...[
              const SizedBox(height: 8),
              Text(
                'Último sorteio: ${_result!.title}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        );
      },
    );
  }
}
