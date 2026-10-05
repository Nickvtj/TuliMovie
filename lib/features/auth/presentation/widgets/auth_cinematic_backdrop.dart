import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/utils/tmdb_image_url.dart';

/// Pôsteres escurecidos + crossfade — fundo do onboarding/login.
class AuthCinematicBackdrop extends StatefulWidget {
  const AuthCinematicBackdrop({super.key});

  static const _posterPaths = [
    '/q6y0WpC0dP2XcAwmFbY4d6kUXfx.jpg', // Matrix
    '/7RyHsO4yDXtBv1zUU3mTpHeQ0d.jpg', // Avengers
    '/b0Pl0SM4j7e3m2afWGlBfLvSSUf.jpg', // Dune
    '/1g0dhYtq4irTY1GPXvft6kYTLYt.jpg', // Spider-Man
    '/sF1U4EUQS8YHUYjNl3pMGNIQyr0.jpg', // Ship
  ];

  @override
  State<AuthCinematicBackdrop> createState() => _AuthCinematicBackdropState();
}

class _AuthCinematicBackdropState extends State<AuthCinematicBackdrop> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % AuthCinematicBackdrop._posterPaths.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = AuthCinematicBackdrop._posterPaths[_index];
    final imageUrl = TmdbImageUrl.poster(path, size: 'w780');

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 900),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: imageUrl == null
              ? const ColoredBox(
                  key: ValueKey('fallback'),
                  color: AppColors.backgroundDeep,
                )
              : Image.network(
                  imageUrl,
                  key: ValueKey(path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: AppColors.backgroundDeep,
                  ),
                ),
        ),
        Container(
          decoration: const BoxDecoration(gradient: AppGradients.backgroundVignette),
        ),
        Container(
          color: Colors.black.withValues(alpha: 0.62),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: const SizedBox.expand(),
        ),
      ],
    );
  }
}
