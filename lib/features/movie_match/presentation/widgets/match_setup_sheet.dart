import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/tuli_bottom_sheet.dart';
import '../../../../core/presentation/widgets/tuli_filter_chip.dart';
import '../../../../core/theme/app_theme.dart';
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
      backgroundColor: Colors.transparent,
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

  void _apply() {
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
  }

  @override
  Widget build(BuildContext context) {
    return TuliBottomSheet(
      title: 'Configurar rodada',
      applyLabel: 'Salvar filtros',
      onCancel: () => Navigator.pop(context),
      onApply: _apply,
      child: SliderTheme(
        data: tuliSliderTheme(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Streaming', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final p in TmdbStreamingProviders.all)
                  TuliFilterChip(
                    label: p.name,
                    selected: _providers.contains(p.id),
                    onSelected: () => setState(() {
                      if (_providers.contains(p.id)) {
                        _providers.remove(p.id);
                      } else {
                        _providers.add(p.id);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Gêneros', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final g in TmdbGenres.matchChips)
                  TuliFilterChip(
                    label: g.label,
                    selected: _genres.contains(g.id),
                    onSelected: () => setState(() {
                      if (_genres.contains(g.id)) {
                        _genres.remove(g.id);
                      } else {
                        _genres.add(g.id);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Época: ${_years.start.round()} – ${_years.end.round()}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            RangeSlider(
              min: 1970,
              max: 2026,
              divisions: 56,
              values: _years,
              onChanged: (v) => setState(() => _years = v),
            ),
            Text('Duração máxima', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
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
              contentPadding: EdgeInsets.zero,
              value: _includeWatchlist,
              onChanged: (v) => setState(() => _includeWatchlist = v),
              title: const Text('Incluir filmes da watchlist do grupo'),
            ),
          ],
        ),
      ),
    );
  }
}
