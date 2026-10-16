import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/core/utils/tmdb_image_url.dart';

void main() {
  test('escolhe o menor pôster do TMDB que cobre a largura', () {
    expect(TmdbImageUrl.posterForWidth('/a.jpg', 120), endsWith('/w154/a.jpg'));
    expect(TmdbImageUrl.posterForWidth('/a.jpg', 340), endsWith('/w342/a.jpg'));
    expect(TmdbImageUrl.posterForWidth('/a.jpg', 92), endsWith('/w92/a.jpg'));
  });

  test('acima do maior tamanho usa w780; sem caminho não gera URL', () {
    expect(TmdbImageUrl.posterForWidth('/a.jpg', 2000), endsWith('/w780/a.jpg'));
    expect(TmdbImageUrl.posterForWidth(null, 200), isNull);
  });
}
