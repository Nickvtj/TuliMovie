import 'package:equatable/equatable.dart';

import 'cast_member_entity.dart';
import 'crew_member_entity.dart';
import 'movie_entity.dart';
import 'streaming_provider_entity.dart';

/// Detalhes completos: elenco, direção e streaming.
class MovieDetailsEntity extends Equatable {
  const MovieDetailsEntity({
    required this.movie,
    this.tagline,
    this.runtimeMinutes,
    this.genres = const [],
    this.cast = const [],
    this.crew = const [],
    this.streamingProviders = const [],
    this.watchRegion = 'BR',
  });

  final MovieEntity movie;
  final String? tagline;
  final int? runtimeMinutes;
  final List<String> genres;
  final List<CastMemberEntity> cast;
  final List<CrewMemberEntity> crew;
  final List<StreamingProviderEntity> streamingProviders;
  final String watchRegion;

  List<CrewMemberEntity> get directors =>
      crew.where((member) => member.isDirector).toList();

  @override
  List<Object?> get props => [
        movie,
        tagline,
        runtimeMinutes,
        genres,
        cast,
        crew,
        streamingProviders,
        watchRegion,
      ];
}
