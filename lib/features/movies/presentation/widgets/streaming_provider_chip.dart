import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/tmdb_image_url.dart';
import '../../domain/entities/streaming_provider_entity.dart';

class StreamingProviderChip extends StatelessWidget {
  const StreamingProviderChip({super.key, required this.provider});

  final StreamingProviderEntity provider;

  @override
  Widget build(BuildContext context) {
    final logo = TmdbImageUrl.poster(provider.logoPath, size: 'w92');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppShape.borderRadiusSm,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: logo,
                width: 22,
                height: 22,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(Icons.tv, size: 18),
              ),
            )
          else
            const Icon(Icons.tv, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(provider.name, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
