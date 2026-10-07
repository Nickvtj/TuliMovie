import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'tuli_icon_button_circle.dart';
import 'tuli_ring_avatar.dart';
import 'tuli_status_dot.dart';

enum TuliTopBarVariant { brand, backTitle }

class TuliTopBar extends StatelessWidget {
  const TuliTopBar({
    super.key,
    this.variant = TuliTopBarVariant.brand,
    this.title,
    this.leadingStatusDot = false,
    this.onBack,
    this.showBackButton = true,
    this.avatarName,
    this.avatarImageUrl,
    this.onAvatarTap,
    this.trailing,
    this.bookmarkCount,
    this.onBookmarkTap,
  });

  final TuliTopBarVariant variant;
  final String? title;
  final bool leadingStatusDot;
  final VoidCallback? onBack;
  final bool showBackButton;
  final String? avatarName;
  final String? avatarImageUrl;
  final VoidCallback? onAvatarTap;
  final Widget? trailing;
  final int? bookmarkCount;
  final VoidCallback? onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
      child: Row(
        children: [
          if (variant == TuliTopBarVariant.backTitle) ...[
            if (showBackButton) ...[
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
              child: Text(
                title ?? '',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ] else ...[
            const _BrandMark(compact: true),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  children: const [
                    TextSpan(text: 'Tuli ', style: TextStyle(color: AppColors.textPrimary)),
                    TextSpan(text: 'Movie', style: TextStyle(color: AppColors.gold)),
                  ],
                ),
              ),
            ),
          ],
          if (onBookmarkTap != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: TuliIconButtonCircle(
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
            ),
          if (trailing != null) trailing!,
          if (avatarName != null)
            GestureDetector(
              onTap: onAvatarTap,
              child: TuliRingAvatar(
                displayName: avatarName!,
                imageUrl: avatarImageUrl,
                size: 36,
              ),
            ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 36.0 : 48.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.gold.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(Icons.local_movies_rounded, color: AppColors.gold, size: size * 0.5),
    );
  }
}
