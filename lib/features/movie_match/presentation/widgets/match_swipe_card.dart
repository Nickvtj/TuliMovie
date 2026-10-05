import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/match_candidate_entity.dart';

class MatchSwipeCard extends StatelessWidget {
  const MatchSwipeCard({super.key, required this.candidate});

  final MatchCandidateEntity candidate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final year = candidate.releaseYear != null ? ' (${candidate.releaseYear})' : '';

    return TuliCard(
      variant: TuliCardVariant.elevated,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: TuliPosterImage(
                posterPath: candidate.posterPath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${candidate.title}$year',
            style: textTheme.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (candidate.overview != null && candidate.overview!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              candidate.overview!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
