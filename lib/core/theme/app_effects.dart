import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Intensidade de efeitos visuais (brilhos, sombras, animações contínuas).
abstract final class AppEffects {
  /// iPhone/iPad no navegador: o Safari desenha via WebGL do iOS, onde desfoque
  /// grande e animação contínua custam caro e deixam o app lento.
  static bool get reduced => kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static const _reducedMaxBlur = 6.0;

  /// Raio de desfoque de sombras/brilhos — limitado no iPhone.
  static double blur(double radius) => reduced ? math.min(radius, _reducedMaxBlur) : radius;
}
