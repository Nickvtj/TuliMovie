import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';

/// Fundo do login — só gradiente (sem TMDB) para não poluir a rede com 404.
class AuthCinematicBackdrop extends StatefulWidget {
  const AuthCinematicBackdrop({super.key});

  @override
  State<AuthCinematicBackdrop> createState() => _AuthCinematicBackdropState();
}

class _AuthCinematicBackdropState extends State<AuthCinematicBackdrop> {
  double _phase = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 48), (_) {
      if (!mounted) return;
      setState(() => _phase = (_phase + 0.012) % 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + _phase * 2, -0.8),
              end: Alignment(1 - _phase * 2, 0.9),
              colors: const [
                AppColors.backgroundDeep,
                Color(0xFF1A1024),
                Color(0xFF0F1419),
                AppColors.backgroundDeep,
              ],
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(gradient: AppGradients.backgroundVignette),
        ),
        Container(
          color: Colors.black.withValues(alpha: 0.55),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: const SizedBox.expand(),
        ),
      ],
    );
  }
}
