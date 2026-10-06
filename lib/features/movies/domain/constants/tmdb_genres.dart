/// IDs de gênero TMDB usados nos filtros de Match / Descubra.
abstract final class TmdbGenres {
  static const action = 28;
  static const comedy = 35;
  static const horror = 27;
  static const sciFi = 878;
  static const animation = 16;
  static const thriller = 53;
  static const drama = 18;
  static const romance = 10749;
  static const adventure = 12;
  static const fantasy = 14;

  static const matchChips = [
    (id: action, label: 'Ação'),
    (id: comedy, label: 'Comédia'),
    (id: horror, label: 'Terror'),
    (id: sciFi, label: 'Sci-Fi'),
    (id: animation, label: 'Animação'),
    (id: thriller, label: 'Suspense'),
    (id: drama, label: 'Drama'),
  ];

  static const discoverGenreChips = [
    (id: action, label: 'Ação'),
    (id: comedy, label: 'Comédia'),
    (id: drama, label: 'Drama'),
    (id: horror, label: 'Terror'),
    (id: sciFi, label: 'Sci-Fi'),
    (id: romance, label: 'Romance'),
    (id: adventure, label: 'Aventura'),
    (id: animation, label: 'Animação'),
    (id: fantasy, label: 'Fantasia'),
    (id: thriller, label: 'Suspense'),
  ];

  static String? labelFor(int id) {
    for (final chip in discoverGenreChips) {
      if (chip.id == id) return chip.label;
    }
    for (final chip in matchChips) {
      if (chip.id == id) return chip.label;
    }
    return null;
  }
}
