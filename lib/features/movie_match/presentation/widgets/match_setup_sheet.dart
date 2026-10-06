import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../movies/domain/constants/tmdb_genres.dart';
import '../../../movies/domain/constants/tmdb_streaming_providers.dart';
import '../../domain/entities/match_filters_entity.dart';

class MatchSetupSheet extends StatefulWidget {
  const MatchSetupSheet({super.key, required this.initial});

  final MatchFiltersEntity initial;

  static Future<MatchFiltersEntity?> show(
    BuildContext context, {
    MatchFiltersEntity initial = const MatchFiltersEntity(),
  }) {
    return showModalBottomSheet<MatchFiltersEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => MatchSetupSheet(initial: initial),
    );
  }

  @override
  State<MatchSetupSheet> createState() => _MatchSetupSheetState();
}

class _MatchSetupSheetState extends State<MatchSetupSheet> {
  late final Set<int> _providers = {...widget.initial.withWatchProviderIds};
  late final Set<int> _genres = {...widget.initial.genreIds};
  late RangeValues _years = RangeValues(
    (widget.initial.releaseYearFrom ?? 1980).toDouble(),
    (widget.initial.releaseYearTo ?? 2026).toDouble(),
  );
  late int? _maxRuntime = widget.initial.maxRuntimeMinutes;
  late bool _includeWatchlist = widget.initial.includeGroupWatchlist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Configurar rodada', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Streaming', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: [
                for (final p in TmdbStreamingProviders.all)
                  FilterChip(
                    label: Text(p.name),
                    selected: _providers.contains(p.id),
                    onSelected: (v) => setState(() {
                      v ? _providers.add(p.id) : _providers.remove(p.id);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Gêneros', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: [
                for (final g in TmdbGenres.matchChips)
                  FilterChip(
                    label: Text(g.label),
                    selected: _genres.contains(g.id),
                    onSelected: (v) => setState(() {
                      v ? _genres.add(g.id) : _genres.remove(g.id);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Época: ${_years.start.round()} – ${_years.end.round()}'),
            RangeSlider(
              min: 1970,
              max: 2026,
              divisions: 56,
              activeColor: AppColors.gold,
              values: _years,
              onChanged: (v) => setState(() => _years = v),
            ),
            Text('Duração máxima', style: Theme.of(context).textTheme.titleSmall),
            SegmentedButton<int?>(
              segments: const [
                ButtonSegment(value: null, label: Text('Qualquer')),
                ButtonSegment(value: 90, label: Text('≤ 90')),
                ButtonSegment(value: 120, label: Text('≤ 120')),
              ],
              selected: {_maxRuntime},
              onSelectionChanged: (set) => setState(() => _maxRuntime = set.first),
            ),
            SwitchListTile(
              value: _includeWatchlist,
              onChanged: (v) => setState(() => _includeWatchlist = v),
              title: const Text('Incluir filmes da watchlist do grupo'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  MatchFiltersEntity(
                    withWatchProviderIds: _providers.toList(),
                    genreIds: _genres.toList(),
                    releaseYearFrom: _years.start.round(),
                    releaseYearTo: _years.end.round(),
                    maxRuntimeMinutes: _maxRuntime,
                    includeGroupWatchlist: _includeWatchlist,
                  ),
                );
              },
              child: const Text('Salvar filtros'),
            ),
          ],
        ),
      ),
    );
  }
}
