import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/tmdb_image_url.dart';
import 'tuli_shimmer_loader.dart';

/// Poster TMDB com cache — único ponto DRY para capas.
class TuliPosterImage extends StatelessWidget {
  const TuliPosterImage({
    super.key,
    required this.posterPath,
    this.width = 72,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String? posterPath;
  final double width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final h = height ?? width * 1.5;
    final radius = borderRadius ?? AppShape.borderRadiusSm;
    final url = TmdbImageUrl.poster(posterPath);

    if (url == null) {
      return _Placeholder(width: width, height: h, borderRadius: radius);
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: h,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: fit,
          memCacheWidth: (width * 2).toInt(),
          placeholder: (_, __) => TuliShimmerLoader(
            child: TuliShimmerBox(width: width, height: h, borderRadius: radius),
          ),
          errorWidget: (_, __, ___) => _Placeholder(width: width, height: h, borderRadius: radius),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.movie_outlined, color: AppColors.textMuted),
    );
  }
}
