import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../movies/domain/constants/tmdb_genres.dart';
import '../../../movies/domain/constants/tmdb_streaming_providers.dart';
import '../../domain/entities/match_filters_entity.dart';

class MatchActiveFiltersBar extends StatelessWidget {
  const MatchActiveFiltersBar({super.key, required this.filters});

  final MatchFiltersEntity filters;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[];

    for (final id in filters.genreIds) {
      final label = TmdbGenres.matchChips.where((g) => g.id == id).map((g) => g.label).firstOrNull;
      if (label != null) chips.add(label);
    }
    for (final id in filters.withWatchProviderIds) {
      final label =
          TmdbStreamingProviders.all.where((p) => p.id == id).map((p) => p.name).firstOrNull;
      if (label != null) chips.add(label);
    }
    if (filters.maxRuntimeMinutes != null) {
      chips.add('⏳ < ${filters.maxRuntimeMinutes} min');
    }
    if (filters.includeGroupWatchlist) chips.add('📋 Watchlist');

    if (chips.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(c, style: Theme.of(context).textTheme.labelSmall),
                  backgroundColor: AppColors.surfaceMuted,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
