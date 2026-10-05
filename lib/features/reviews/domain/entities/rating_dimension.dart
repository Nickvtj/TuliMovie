/// As 5 perguntas padrão do TuliMovie (escala 1–5).
enum RatingDimension {
  plot,
  acting,
  visuals,
  soundtrack,
  fun,
}

extension RatingDimensionLabels on RatingDimension {
  String get title {
    return switch (this) {
      RatingDimension.plot => 'Enredo & Roteiro',
      RatingDimension.acting => 'Atuação & Personagens',
      RatingDimension.visuals => 'Visuais & Direção',
      RatingDimension.soundtrack => 'Trilha Sonora & Som',
      RatingDimension.fun => 'Fator Divertimento',
    };
  }

  String get subtitle {
    return switch (this) {
      RatingDimension.plot => 'A história fez sentido e te prendeu?',
      RatingDimension.acting => 'Você se importou com os personagens?',
      RatingDimension.visuals => 'Fotografia, cenários e efeitos',
      RatingDimension.soundtrack => 'Música e som agregaram à cena?',
      RatingDimension.fun => 'O tempo passou rápido e valeu a pena?',
    };
  }

  static List<RatingDimension> get all => RatingDimension.values;
}
