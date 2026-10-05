import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_theme.dart';

/// Selo da Discórdia — pulso neon quando há divergência de notas.
class DiscordBadge extends StatefulWidget {
  const DiscordBadge({super.key, this.compact = false});

  final bool compact;

  @override
  State<DiscordBadge> createState() => _DiscordBadgeState();
}

class _DiscordBadgeState extends State<DiscordBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.compact ? 'Discórdia' : 'Selo da Discórdia';

    return ScaleTransition(
      scale: _pulse,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.neonAlert,
          borderRadius: AppShape.borderRadiusSm,
          boxShadow: [
            BoxShadow(
              color: AppColors.neonRed.withValues(alpha: 0.45),
              blurRadius: 14,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 8 : 10,
            vertical: widget.compact ? 4 : 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
