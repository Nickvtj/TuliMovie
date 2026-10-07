import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class TuliMetaRow extends StatelessWidget {
  const TuliMetaRow({
    super.key,
    this.year,
    this.genreLabel,
    this.extra,
  });

  final String? year;
  final String? genreLabel;
  final String? extra;

  @override
  Widget build(BuildContext context) {
    final styleMuted = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textMuted,
          fontSize: 12,
        );
    final styleGenre = styleMuted?.copyWith(
      color: AppColors.gold,
      fontWeight: FontWeight.w600,
    );

    final parts = <Widget>[];
    if (year != null && year!.isNotEmpty) {
      parts.add(Text(year!, style: styleMuted));
    }
    if (genreLabel != null && genreLabel!.isNotEmpty) {
      if (parts.isNotEmpty) parts.add(_bullet(styleMuted));
      parts.add(Text(genreLabel!, style: styleGenre));
    }
    if (extra != null && extra!.isNotEmpty) {
      if (parts.isNotEmpty) parts.add(_bullet(styleMuted));
      parts.add(Text(extra!, style: styleMuted));
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: parts,
    );
  }

  Widget _bullet(TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text('•', style: style),
    );
  }
}
