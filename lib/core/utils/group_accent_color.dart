import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Cor estável por turma (para chips no feed e watchlist).
Color groupAccentColor(String groupId) {
  final hash = groupId.hashCode.abs();
  const palette = [
    AppColors.gold,
    Color(0xFF6EC6FF),
    Color(0xFFB388FF),
    Color(0xFF81C784),
    Color(0xFFFF8A65),
    Color(0xFF4DD0E1),
    Color(0xFFF06292),
  ];
  return palette[hash % palette.length];
}
