import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class TuliStatusDot extends StatelessWidget {
  const TuliStatusDot({super.key, this.size = 10});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gold,
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.75),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
