abstract final class CinephileLabelCalculator {
  static String labelForAverage(double averageRating) {
    if (averageRating >= 4.2) return 'Coração Mole';
    if (averageRating <= 2.8) return 'Ranzinza / Crítico da Folha';
    return 'Equilibrado';
  }
}
