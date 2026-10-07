import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/tuli_filter_chip.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../movies/domain/constants/tmdb_genres.dart';

class DiscoverChipsBarWidget extends StatelessWidget {
  const DiscoverChipsBarWidget({
    super.key,
    required this.selectedGenreId,
    required this.onGenreSelected,
  });

  final int? selectedGenreId;
  final ValueChanged<int?> onGenreSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: TuliFilterChip(
              label: 'Todos',
              selected: selectedGenreId == null,
              onSelected: () => onGenreSelected(null),
            ),
          ),
          for (final genre in TmdbGenres.discoverGenreChips)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: TuliFilterChip(
                label: genre.label,
                selected: selectedGenreId == genre.id,
                onSelected: () => onGenreSelected(genre.id),
              ),
            ),
        ],
      ),
    );
  }
}
