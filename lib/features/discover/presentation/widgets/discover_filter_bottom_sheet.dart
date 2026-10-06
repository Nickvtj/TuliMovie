import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
      backgroundColor: AppColors.surface,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filtros avançados', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text('Streaming', style: Theme.of(context).textTheme.titleSmall),
          Wrap(
            spacing: 8,
            children: [
              for (final provider in TmdbStreamingProviders.all)
                FilterChip(
                  label: Text(provider.name),
                  selected: _providers.contains(provider.id),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _providers.add(provider.id);
                      } else {
                        _providers.remove(provider.id);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Década de lançamento', style: Theme.of(context).textTheme.titleSmall),
          RangeSlider(
            min: 1970,
            max: DiscoverFilterDefaults.currentYear.toDouble(),
            divisions: 5,
            activeColor: AppColors.gold,
            values: _decadeRange,
            labels: RangeLabels(
              _decadeRange.start.round().toString(),
              _decadeRange.end.round().toString(),
            ),
            onChanged: (values) => setState(() => _decadeRange = values),
          ),
          Text('Nota mínima TMDB: ${_minVote.toStringAsFixed(1)}'),
          Slider(
            min: 0,
            max: 9,
            divisions: 18,
            activeColor: AppColors.gold,
            value: _minVote,
            onChanged: (v) => setState(() => _minVote = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      widget.initial.copyWith(
                        withWatchProviderIds: _providers.toList(),
                        releaseYearFrom: _decadeRange.start.round(),
                        releaseYearTo: _decadeRange.end.round(),
                        minVoteAverage: _minVote <= 0 ? null : _minVote,
                      ),
                    );
                  },
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
