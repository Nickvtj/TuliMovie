import '../../../movies/domain/entities/movie_entity.dart';

class DiscoverSectionEntity {
  const DiscoverSectionEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.movies,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<MovieEntity> movies;
}

class DiscoverHomeEntity {
  const DiscoverHomeEntity({required this.sections});

  final List<DiscoverSectionEntity> sections;
}
