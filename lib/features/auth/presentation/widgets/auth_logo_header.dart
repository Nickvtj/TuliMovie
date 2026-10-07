import 'dart:ui';

import 'package:flutter/material.dart';

import 'auth_tokens.dart';

class AuthWelcomeHero extends StatelessWidget {
  const AuthWelcomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _WelcomeLogoBadge(),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            style: AuthTokens.welcomeBrand,
            children: const [
              TextSpan(text: 'Tuli ', style: TextStyle(color: AuthTokens.textPrimary)),
              TextSpan(text: 'Movie', style: TextStyle(color: AuthTokens.primaryYellow)),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const Text(
          'O cinema da turma,',
          style: AuthTokens.welcomeHeadlineLine,
          textAlign: TextAlign.center,
        ),
        const Text(
          'num só lugar.',
          style: AuthTokens.welcomeHeadlineAccent,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Descubra filmes, avalie lançamentos e\ncompartilhe com amigos.',
            style: AuthTokens.welcomeSubhead,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _WelcomeLogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: AuthTokens.logoBoxSize + 24,
          height: AuthTokens.logoBoxSize + 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: AuthTokens.logoGlowStrong,
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(AuthTokens.logoBoxRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AuthTokens.logoBoxRadius),
                color: AuthTokens.primaryYellow.withValues(alpha: 0.1),
                border: Border.all(
                  color: AuthTokens.primaryYellow.withValues(alpha: 0.3),
                ),
              ),
              child: SizedBox(
                width: AuthTokens.logoBoxSize,
                height: AuthTokens.logoBoxSize,
                child: Icon(
                  Icons.local_movies_rounded,
                  size: 32,
                  color: AuthTokens.primaryYellow,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Indicador decorativo (canto superior esquerdo), como no mock.
class AuthWelcomeStatusDot extends StatelessWidget {
  const AuthWelcomeStatusDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AuthTokens.primaryYellow,
        boxShadow: [
          BoxShadow(
            color: AuthTokens.primaryYellow.withValues(alpha: 0.75),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
