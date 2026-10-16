/// Avatares prontos (DiceBear, PNG) — sem upload, sem Firebase Storage.
///
/// O PNG do DiceBear limita ~10 imagens por segundo; acima disso as últimas
/// falham e viram "?". Por isso a galeria fica enxuta.
abstract final class AvatarCatalog {
  static const _baseUrl = 'https://api.dicebear.com/9.x';
  static const _background = '1c1f26';

  /// Estilo + "personagem" de cinema (a seed define o rosto gerado).
  static const _avatars = [
    ('adventurer', 'Diretora'),
    ('adventurer', 'Dubla'),
    ('avataaars', 'Pipoca'),
    ('avataaars', 'Oscar'),
    ('lorelei', 'Estrela'),
    ('lorelei', 'Noir'),
    ('notionists', 'Critico'),
    ('notionists', 'Roteirista'),
  ];

  static final List<String> urls = [
    for (final (style, seed) in _avatars)
      '$_baseUrl/$style/png?seed=$seed&size=192&backgroundColor=$_background',
  ];
}
