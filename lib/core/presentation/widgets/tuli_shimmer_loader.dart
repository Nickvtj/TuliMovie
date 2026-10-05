import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Skeletons padronizados para carregamento assíncrono (DRY).
class TuliShimmerLoader extends StatelessWidget {
  const TuliShimmerLoader({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surfaceElevated,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

class TuliShimmerBox extends StatelessWidget {
  const TuliShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: borderRadius ?? AppShape.borderRadiusSm,
      ),
    );
  }
}

/// Lista estilo feed enquanto carrega reviews.
class TuliFeedSkeleton extends StatelessWidget {
  const TuliFeedSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return TuliShimmerLoader(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => const _FeedCardSkeleton(),
      ),
    );
  }
}

class _FeedCardSkeleton extends StatelessWidget {
  const _FeedCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShape.borderRadiusMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TuliShimmerBox(width: 72, height: 108, borderRadius: BorderRadius.all(Radius.circular(12))),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TuliShimmerBox(width: double.infinity, height: 18),
                SizedBox(height: 8),
                TuliShimmerBox(width: 120, height: 14),
                SizedBox(height: 12),
                TuliShimmerBox(width: 100, height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Poster 2:3 para detalhes de filme.
class TuliPosterSkeleton extends StatelessWidget {
  const TuliPosterSkeleton({super.key, this.width = 140});

  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 1.5;
    return TuliShimmerLoader(
      child: TuliShimmerBox(
        width: width,
        height: height,
        borderRadius: AppShape.borderRadiusMd,
      ),
    );
  }
}
