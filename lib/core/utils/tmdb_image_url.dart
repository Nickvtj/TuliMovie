import '../config/env_config.dart';

/// URLs de imagem TMDB — único ponto para poster/profile/backdrop.
abstract final class TmdbImageUrl {
  static String? poster(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) return null;
    final base = EnvConfig.tmdbImageBaseUrl.replaceAll('/w500', '');
    return '$base/$size$path';
  }

  static String? profile(String? path) => poster(path, size: 'w185');
}
