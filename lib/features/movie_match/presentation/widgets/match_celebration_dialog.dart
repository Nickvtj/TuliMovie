import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/match_candidate_entity.dart';

Future<void> showMatchCelebrationDialog(
  BuildContext context, {
  required MatchCandidateEntity movie,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Match',
    barrierColor: Colors.black87,
    pageBuilder: (context, _, __) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: TuliCard(
            variant: TuliCardVariant.goldAccent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 160,
                  child: Lottie.network(
                    'https://assets10.lottiefiles.com/packages/lf20_touohxv0.json',
                    repeat: false,
                    errorBuilder: (_, __, ___) {
                      return const Icon(Icons.celebration, size: 96, color: AppColors.gold);
                    },
                  ),
                ),
                Text(
                  'MATCH DA TURMA!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.gold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TuliPosterImage(posterPath: movie.posterPath, width: 110),
                const SizedBox(height: 16),
                TuliButton(
                  label: 'Bora assistir!',
                  expand: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
        child: child,
      );
    },
  );
}
