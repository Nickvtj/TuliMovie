/// Variáveis de ambiente via `--dart-define` (nunca commitar chaves reais).
abstract final class EnvConfig {
  static const String tmdbApiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '',
  );

  static const String tmdbBaseUrl = String.fromEnvironment(
    'TMDB_BASE_URL',
    defaultValue: 'https://api.themoviedb.org/3',
  );

  static const String tmdbImageBaseUrl = String.fromEnvironment(
    'TMDB_IMAGE_BASE_URL',
    defaultValue: 'https://image.tmdb.org/t/p/w500',
  );

  static const String tmdbDefaultRegion = String.fromEnvironment(
    'TMDB_DEFAULT_REGION',
    defaultValue: 'BR',
  );

  static bool get hasTmdbApiKey => tmdbApiKey.isNotEmpty;
}
