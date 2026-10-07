import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'user_avatar_group.dart';

/// Avatar com anel colorido (hash do nome do usuário).
class TuliRingAvatar extends StatelessWidget {
  const TuliRingAvatar({
    super.key,
    required this.displayName,
    this.imageUrl,
    this.size = 44,
  });

  final String displayName;
  final String? imageUrl;
  final double size;

  static Color ringColorFor(String seed) {
    final hash = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    const palette = [
      AppColors.gold,
      Color(0xFF60A5FA),
      Color(0xFFA78BFA),
      Color(0xFF34D399),
      Color(0xFFF472B6),
    ];
    return palette[hash % palette.length];
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final token = parts.first;
      return (token.length >= 2 ? token.substring(0, 2) : token).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ring = ringColorFor(displayName);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 2),
      ),
      child: TuliAvatar(
        size: size,
        imageUrl: imageUrl,
        initials: initials(displayName),
      ),
    );
  }
}
