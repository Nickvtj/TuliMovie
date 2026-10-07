import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/tuli_bottom_sheet.dart';
import '../../../../core/presentation/widgets/tuli_filter_chip.dart';
import '../../../../core/presentation/widgets/tuli_score_pill.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../movies/domain/constants/tmdb_streaming_providers.dart';
import '../../domain/entities/discover_filter_entity.dart';

class DiscoverFilterBottomSheet extends StatefulWidget {
  const DiscoverFilterBottomSheet({super.key, required this.initial});

  final DiscoverFilterEntity initial;

  static Future<DiscoverFilterEntity?> show(
    BuildContext context, {
    required DiscoverFilterEntity initial,
  }) {
    return showModalBottomSheet<DiscoverFilterEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DiscoverFilterBottomSheet(initial: initial),
    );
  }

  @override
  State<DiscoverFilterBottomSheet> createState() => _DiscoverFilterBottomSheetState();
}

class _DiscoverFilterBottomSheetState extends State<DiscoverFilterBottomSheet> {
  late final Set<int> _providers = {...widget.initial.withWatchProviderIds};
  late double _minVote = widget.initial.minVoteAverage ?? 0;
  late RangeValues _decadeRange = RangeValues(
    (widget.initial.releaseYearFrom ?? 1980).toDouble(),
    (widget.initial.releaseYearTo ?? DiscoverFilterDefaults.currentYear).toDouble(),
  );

  void _apply() {
    Navigator.pop(
      context,
      widget.initial.copyWith(
        withWatchProviderIds: _providers.toList(),
        releaseYearFrom: _decadeRange.start.round(),
        releaseYearTo: _decadeRange.end.round(),
        minVoteAverage: _minVote <= 0 ? null : _minVote,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TuliBottomSheet(
      title: 'Filtros avançados',
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
                for (final provider in TmdbStreamingProviders.all)
                  TuliFilterChip(
                    label: provider.name,
                    selected: _providers.contains(provider.id),
                    onSelected: () {
                      setState(() {
                        if (_providers.contains(provider.id)) {
                          _providers.remove(provider.id);
                        } else {
                          _providers.add(provider.id);
                        }
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Década de lançamento', style: Theme.of(context).textTheme.titleSmall),
            RangeSlider(
              min: 1970,
              max: DiscoverFilterDefaults.currentYear.toDouble(),
              divisions: 5,
              values: _decadeRange,
              labels: RangeLabels(
                _decadeRange.start.round().toString(),
                _decadeRange.end.round().toString(),
              ),
              onChanged: (values) => setState(() => _decadeRange = values),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text('Nota mínima TMDB', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                TuliScorePill(score: _minVote, compact: true),
              ],
            ),
            Slider(
              min: 0,
              max: 9,
              divisions: 18,
              value: _minVote,
              onChanged: (v) => setState(() => _minVote = v),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
