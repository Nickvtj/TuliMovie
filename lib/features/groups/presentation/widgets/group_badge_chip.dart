import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/group_accent_color.dart';

class GroupBadgeChip extends StatelessWidget {
  const GroupBadgeChip({
    super.key,
    required this.groupId,
    required this.label,
    this.compact = false,
  });

  final String groupId;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = groupAccentColor(groupId);
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 10 : 11,
        );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppShape.borderRadiusPill,
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(label, style: textStyle),
    );
  }
}
