import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../movies/domain/constants/tmdb_genres.dart';

class DiscoverChipsBarWidget extends StatelessWidget {
  const DiscoverChipsBarWidget({
    super.key,
    required this.selectedGenreId,
    required this.onGenreSelected,
    required this.onOpenAdvancedFilters,
  });

  final int? selectedGenreId;
  final ValueChanged<int?> onGenreSelected;
  final VoidCallback onOpenAdvancedFilters;

  static const _filterButtonWidth = 52.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        children: [
          ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 12, right: _filterButtonWidth + 8),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Todos'),
                  selected: selectedGenreId == null,
                  selectedColor: AppColors.gold.withValues(alpha: 0.25),
                  onSelected: (_) => onGenreSelected(null),
                ),
              ),
              for (final genre in TmdbGenres.discoverGenreChips)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(genre.label),
                    selected: selectedGenreId == genre.id,
                    selectedColor: AppColors.gold.withValues(alpha: 0.25),
                    onSelected: (_) => onGenreSelected(genre.id),
                  ),
                ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Material(
              color: AppColors.surface,
              elevation: 4,
              shadowColor: Colors.black54,
              child: IconButton(
                tooltip: 'Filtros avançados',
                icon: const Icon(Icons.tune),
                color: AppColors.gold,
                onPressed: onOpenAdvancedFilters,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
