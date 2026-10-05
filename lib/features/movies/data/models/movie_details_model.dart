import 'cast_member_model.dart';
import 'crew_member_model.dart';
import 'movie_model.dart';
import 'watch_providers_model.dart';

class MovieDetailsModel {
  const MovieDetailsModel({
    required this.movie,
    this.tagline,
    this.runtimeMinutes,
    this.genres = const [],
    this.cast = const [],
    this.crew = const [],
    this.watchProviders,
  });

  final MovieModel movie;
  final String? tagline;
  final int? runtimeMinutes;
  final List<String> genres;
  final List<CastMemberModel> cast;
  final List<CrewMemberModel> crew;
  final WatchProvidersPayloadModel? watchProviders;

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    final credits = json['credits'] as Map<String, dynamic>?;
    final watchProvidersRaw = json['watch/providers'] as Map<String, dynamic>?;

    final genres = (json['genres'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((g) => g['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    return MovieDetailsModel(
      movie: MovieModel.fromJson(json),
      tagline: json['tagline'] as String?,
      runtimeMinutes: (json['runtime'] as num?)?.toInt(),
      genres: genres,
      cast: (credits?['cast'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CastMemberModel.fromJson)
          .toList(),
      crew: (credits?['crew'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CrewMemberModel.fromJson)
          .toList(),
      watchProviders: watchProvidersRaw == null
          ? null
          : WatchProvidersPayloadModel.fromJson(watchProvidersRaw),
    );
  }
}
