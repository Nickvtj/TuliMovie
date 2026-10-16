import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Título de bloco dentro de uma tela, com contador ou ação opcional à direita.
class TuliSectionTitle extends StatelessWidget {
  const TuliSectionTitle({
    super.key,
    required this.title,
    this.trailing,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;

  /// Texto informativo em dourado (ex.: "2 selecionados").
  final String? trailing;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ),
        if (trailing != null)
          Text(trailing!, style: textTheme.labelMedium?.copyWith(color: AppColors.gold)),
        if (actionLabel != null && onAction != null)
          TextButton.icon(
            onPressed: onAction,
            icon: Icon(actionIcon ?? Icons.edit_outlined, size: 16),
            label: Text(actionLabel!),
          ),
      ],
    );
  }
}
