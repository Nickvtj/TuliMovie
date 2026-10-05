import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/tools_providers.dart';

/// Fila circular — destaca quem escolhe o filme da semana.
class CinepassWidget extends ConsumerWidget {
  const CinepassWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(cinepassStateProvider);
    final textTheme = Theme.of(context).textTheme;

    return stateAsync.when(
      loading: () => const TuliShimmerLoader(
        child: TuliShimmerBox(width: double.infinity, height: 120),
      ),
      error: (_, __) => const Text('Cinepass indisponível.'),
      data: (state) {
        if (state.queue.isEmpty) {
          return TuliCard(
            child: Text(
              'Configure a fila do Cinepass no Firestore (cinepass/queue).',
              style: textTheme.bodyMedium,
            ),
          );
        }

        final current = state.current!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TuliCard(
              variant: TuliCardVariant.goldAccent,
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number, color: AppColors.gold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Escolhe esta semana', style: textTheme.labelMedium),
                        Text(
                          current.displayName,
                          style: textTheme.headlineSmall?.copyWith(color: AppColors.gold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.queue.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final entry = state.queue[index];
                  final isCurrent = entry.userId == current.userId;

                  return TuliCard(
                    variant: isCurrent ? TuliCardVariant.goldAccent : TuliCardVariant.standard,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Text(
                      entry.displayName,
                      style: textTheme.labelMedium?.copyWith(
                        color: isCurrent ? AppColors.gold : AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
