import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'tuli_icon_button_circle.dart';
import 'tuli_status_dot.dart';

enum TuliScreenHeaderMode { root, stacked }

/// Cabeçalho padronizado das telas (raiz das abas ou empilhadas com voltar).
class TuliScreenHeader extends StatelessWidget {
  const TuliScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.mode = TuliScreenHeaderMode.root,
    this.leadingStatusDot = false,
    this.onBack,
    this.showBackButton = true,
    this.trailingActions = const [],
    this.onBookmarkTap,
    this.bookmarkCount,
    this.onFilterTap,
  });

  final String title;
  final String? subtitle;
  final TuliScreenHeaderMode mode;
  final bool leadingStatusDot;
  final VoidCallback? onBack;
  final bool showBackButton;
  final List<Widget> trailingActions;
  final VoidCallback? onBookmarkTap;
  final int? bookmarkCount;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = mode == TuliScreenHeaderMode.root
        ? textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)
        : textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.section,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mode == TuliScreenHeaderMode.stacked && showBackButton) ...[
            TuliIconButtonCircle(
              icon: Icons.arrow_back_rounded,
              onPressed: onBack ?? () => Navigator.maybeOf(context)?.pop(),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          if (leadingStatusDot) ...[
            const TuliStatusDot(),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (onBookmarkTap != null) ...[
            TuliIconButtonCircle(
              icon: Icons.bookmark_rounded,
              onPressed: onBookmarkTap,
              tooltip: 'Watchlist',
              badge: (bookmarkCount ?? 0) > 0
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (onFilterTap != null) ...[
            TuliIconButtonCircle(
              icon: Icons.tune_rounded,
              onPressed: onFilterTap,
              tooltip: 'Filtros',
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          ...trailingActions,
        ],
      ),
    );
  }
}
