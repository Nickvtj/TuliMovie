/// IDs TMDB (BR) — compartilhado entre Descubra e Match.
abstract final class TmdbStreamingProviders {
  static const netflix = 8;
  static const primeVideo = 9;
  static const disneyPlus = 337;
  static const max = 384;

  static const all = [
    (id: netflix, name: 'Netflix'),
    (id: primeVideo, name: 'Prime Video'),
    (id: disneyPlus, name: 'Disney+'),
    (id: max, name: 'Max'),
  ];
}
