import 'dart:ui';

import 'package:flutter/material.dart';

import '../state/auth_form_state.dart';
import 'auth_assets.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.step});

  final AuthFormStep step;

  @override
  Widget build(BuildContext context) {
    if (step == AuthFormStep.welcome) {
      return const _WelcomeBackground();
    }
    return _LoginBackground(height: MediaQuery.sizeOf(context).height);
  }
}

class _WelcomeBackground extends StatelessWidget {
  const _WelcomeBackground();

  static const _pageBg = Color(0xFF0D0E12);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _pageBg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AuthAssets.welcomeBackground,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => const ColoredBox(color: _pageBg),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _pageBg.withValues(alpha: 0.4),
                  _pageBg.withValues(alpha: 0.75),
                  _pageBg.withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.15,
                colors: [
                  Colors.transparent,
                  _pageBg.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground({required this.height});

  final double height;

  static const _pageBg = Color(0xFF0D0E12);

  @override
  Widget build(BuildContext context) {
    final imageHeight = height * 0.40;

    return ColoredBox(
      color: _pageBg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: imageHeight,
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.72, 0, 0, 0, 0,
                      0, 0.72, 0, 0, 0,
                      0, 0, 0.72, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Image.asset(
                        AuthAssets.loginBackground,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        width: double.infinity,
                        height: imageHeight * 1.1,
                        errorBuilder: (_, __, ___) => const ColoredBox(color: _pageBg),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _pageBg.withValues(alpha: 0.12),
                          _pageBg.withValues(alpha: 0.55),
                          _pageBg,
                        ],
                        stops: const [0.0, 0.65, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
