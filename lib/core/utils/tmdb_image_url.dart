import '../config/env_config.dart';

/// URLs de imagem TMDB — único ponto para poster/profile/backdrop.
abstract final class TmdbImageUrl {
  /// Larguras de pôster oferecidas pelo TMDB (`w92` … `w780`).
  static const _posterWidths = [92, 154, 185, 342, 500, 780];

  static String? poster(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) return null;
    final base = EnvConfig.tmdbImageBaseUrl.replaceAll('/w500', '');
    return '$base/$size$path';
  }

  /// Menor pôster do TMDB que cobre [pixelWidth] — evita baixar `w500`
  /// para miniaturas (pesa no celular, principalmente no iPhone).
  static String? posterForWidth(String? path, double pixelWidth) {
    final width = _posterWidths.firstWhere(
      (w) => w >= pixelWidth,
      orElse: () => _posterWidths.last,
    );
    return poster(path, size: 'w$width');
  }

  static String? profile(String? path) => poster(path, size: 'w185');

  static String? backdrop(String? path, {String size = 'w780'}) => poster(path, size: size);
}
