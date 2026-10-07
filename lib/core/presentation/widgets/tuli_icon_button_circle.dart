import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class TuliIconButtonCircle extends StatelessWidget {
  const TuliIconButtonCircle({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.badge,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Widget? badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.surfaceElevated,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.borderElevated),
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.5, color: AppColors.textSecondary),
        ),
      ),
    );

    final wrapped = badge == null
        ? button
        : Stack(
            clipBehavior: Clip.none,
            children: [
              button,
              Positioned(top: 2, right: 2, child: badge!),
            ],
          );

    if (tooltip == null) return wrapped;
    return Tooltip(message: tooltip!, child: wrapped);
  }
}
