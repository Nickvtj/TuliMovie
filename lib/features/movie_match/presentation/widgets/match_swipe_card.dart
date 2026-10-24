import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_effects.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/match_candidate_entity.dart';

/// Card do swipe: pôster em tela cheia com informações sobre o gradiente.
class MatchSwipeCard extends StatelessWidget {
  const MatchSwipeCard({
    super.key,
    required this.candidate,
    this.likedByIds = const [],
    this.dragPercent = 0,
  });

  final MatchCandidateEntity candidate;

  /// Amigos da sala que já curtiram este filme.
  final List<String> likedByIds;

  /// Arraste horizontal em % do limite do swipe (negativo = esquerda).
  final int dragPercent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stampOpacity = (dragPercent.abs() / 100).clamp(0.0, 1.0);
    final overview = candidate.overview?.trim() ?? '';

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppShape.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: AppEffects.blur(24),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppShape.borderRadiusLg,
        child: Stack(
          fit: StackFit.expand,
          children: [
            TuliPosterImage(
              posterPath: candidate.posterPath,
              expand: true,
              borderRadius: BorderRadius.zero,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 0.72, 1],
                  colors: [Colors.transparent, Color(0xB30D0E12), Color(0xF50D0E12)],
                ),
              ),
            ),
            if (likedByIds.isNotEmpty)
              Positioned(
                top: AppSpacing.lg,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _LikedByBadge(userIds: likedByIds),
                ),
              ),
            Positioned(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: AppSpacing.xl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  if (candidate.releaseYear != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    TuliMetaRow(year: '${candidate.releaseYear}'),
                  ],
                  if (overview.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (dragPercent > 0)
              Positioned(
                top: 56,
                left: AppSpacing.xl,
                child: _SwipeStamp(
                  label: 'CURTI',
                  color: AppColors.gold,
                  angle: -0.22,
                  opacity: stampOpacity,
                ),
              ),
            if (dragPercent < 0)
              Positioned(
                top: 56,
                right: AppSpacing.xl,
                child: _SwipeStamp(
                  label: 'NOPE',
                  color: AppColors.neonRed,
                  angle: 0.22,
                  opacity: stampOpacity,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Selo "❤ Ana e Bia curtiram" — quem da sala já deu like neste filme.
class _LikedByBadge extends ConsumerWidget {
  const _LikedByBadge({required this.userIds});

  final List<String> userIds;

  String _label(List<String> names) {
    final total = userIds.length;
    final verb = total == 1 ? 'curtiu' : 'curtiram';
    if (names.isEmpty) return '$total $verb';
    if (total == 1) return '${names.first} $verb';
    if (total == 2 && names.length == 2) return '${names[0]} e ${names[1]} $verb';
    return '${names.first} e +${total - 1} $verb';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = [
      for (final id in userIds.take(2))
        ref.watch(userProfileProvider(id)).valueOrNull?.displayName.split(' ').first,
    ].whereType<String>().toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: AppShape.borderRadiusPill,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_rounded, size: 14, color: AppColors.gold),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _label(names),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeStamp extends StatelessWidget {
  const _SwipeStamp({
    required this.label,
    required this.color,
    required this.angle,
    required this.opacity,
  });

  final String label;
  final Color color;
  final double angle;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            borderRadius: AppShape.borderRadiusSm,
            border: Border.all(color: color, width: 3),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
          ),
        ),
      ),
    );
  }
}
