/// Badge de vibe do cinéfilo para exibição no perfil.
String profileVibeDisplay(String cinephileLabel) {
  if (cinephileLabel.contains('Coração')) return '🍿 $cinephileLabel';
  if (cinephileLabel.contains('Crítico') || cinephileLabel.contains('Ranzinza')) {
    return '🔥 $cinephileLabel';
  }
  return '🎬 $cinephileLabel';
}
