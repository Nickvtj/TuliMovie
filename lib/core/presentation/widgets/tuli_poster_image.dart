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
    this.expand = false,
  });

  final String? posterPath;
  final double width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  /// Preenche o espaço do pai (ex.: card de swipe). Evita passar [double.infinity] em [width].
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppShape.borderRadiusSm;

    if (expand) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return _PosterBody(
            posterPath: posterPath,
            width: w,
            height: h,
            borderRadius: radius,
            fit: fit,
          );
        },
      );
    }

    final h = height ?? width * 1.5;
    return _PosterBody(
      posterPath: posterPath,
      width: width,
      height: h,
      borderRadius: radius,
      fit: fit,
    );
  }
}

class _PosterBody extends StatelessWidget {
  const _PosterBody({
    required this.posterPath,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.fit,
  });

  final String? posterPath;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final BoxFit fit;

  int? get _memCacheWidth {
    if (!width.isFinite || width <= 0) return 600;
    return (width * 2).clamp(1, 2048).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final url = TmdbImageUrl.poster(posterPath);

    if (url == null) {
      return _Placeholder(width: width, height: height, borderRadius: borderRadius, expand: true);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width.isFinite ? width : null,
        height: height.isFinite ? height : null,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: fit,
          width: width.isFinite ? width : null,
          height: height.isFinite ? height : null,
          memCacheWidth: _memCacheWidth,
          placeholder: (_, __) => TuliShimmerLoader(
            child: _Placeholder(
              width: width,
              height: height,
              borderRadius: borderRadius,
              expand: true,
            ),
          ),
          errorWidget: (_, __, ___) => _Placeholder(
            width: width,
            height: height,
            borderRadius: borderRadius,
            expand: true,
          ),
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
    this.expand = false,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expand || !width.isFinite ? double.infinity : width,
      height: expand || !height.isFinite ? double.infinity : height,
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
