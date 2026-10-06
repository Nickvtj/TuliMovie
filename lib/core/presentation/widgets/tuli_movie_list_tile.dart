import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'tuli_card.dart';
import 'tuli_poster_image.dart';

/// Linha padrão filme (poster + título + ano) — DRY busca/descubra.
class TuliMovieListTile extends StatelessWidget {
  const TuliMovieListTile({
    super.key,
    required this.title,
    this.posterPath,
    this.subtitle,
    this.onTap,
    this.trailing = const Icon(Icons.chevron_right, color: AppColors.textMuted),
  });

  final String title;
  final String? posterPath;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return TuliCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          TuliPosterImage(posterPath: posterPath, width: 56),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
