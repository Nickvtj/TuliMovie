import 'package:flutter/material.dart';

import 'tuli_screen_header.dart';

/// Cabeçalho de seção — delega para [TuliScreenHeader] (modo raiz).
class TuliSectionHeader extends StatelessWidget {
  const TuliSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onFilterTap,
    this.onBookmarkTap,
    this.bookmarkCount,
    this.trailingActions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onFilterTap;
  final VoidCallback? onBookmarkTap;
  final int? bookmarkCount;
  final List<Widget> trailingActions;

  @override
  Widget build(BuildContext context) {
    return TuliScreenHeader(
      mode: TuliScreenHeaderMode.root,
      title: title,
      subtitle: subtitle,
      onBookmarkTap: onBookmarkTap,
      bookmarkCount: bookmarkCount,
      onFilterTap: onFilterTap,
      trailingActions: trailing == null ? trailingActions : [...trailingActions, trailing!],
    );
  }
}
