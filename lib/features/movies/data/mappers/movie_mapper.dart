import '../../domain/entities/cast_member_entity.dart';
import '../../domain/entities/crew_member_entity.dart';
import '../../domain/entities/movie_details_entity.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/streaming_provider_entity.dart';
import '../models/cast_member_model.dart';
import '../models/crew_member_model.dart';
import '../models/movie_details_model.dart';
import '../models/movie_model.dart';
import '../models/watch_providers_model.dart';

abstract final class MovieMapper {
  static MovieEntity toEntity(MovieModel model) {
    return MovieEntity(
      id: model.id,
      title: model.title,
      originalTitle: model.originalTitle,
      overview: model.overview,
      posterPath: model.posterPath,
      backdropPath: model.backdropPath,
      releaseDate: model.releaseDate,
      voteAverage: model.voteAverage,
      genreIds: model.genreIds,
    );
  }

  static List<MovieEntity> toEntityList(List<MovieModel> models) =>
      models.map(toEntity).toList();

  static CastMemberEntity castToEntity(CastMemberModel model) {
    return CastMemberEntity(
      id: model.id,
      name: model.name,
      character: model.character,
      profilePath: model.profilePath,
      order: model.order,
    );
  }

  static CrewMemberEntity crewToEntity(CrewMemberModel model) {
    return CrewMemberEntity(
      id: model.id,
      name: model.name,
      job: model.job,
      department: model.department,
      profilePath: model.profilePath,
    );
  }

  static List<StreamingProviderEntity> providersForRegion(
    WatchProvidersPayloadModel? payload,
    String region,
  ) {
    if (payload == null) return const [];

    final regionData = payload.forRegion(region);
    if (regionData == null) return const [];

    StreamingProviderEntity mapProvider(
      WatchProviderModel provider,
      StreamingAvailability availability,
    ) {
      return StreamingProviderEntity(
        providerId: provider.providerId,
        name: provider.providerName,
        logoPath: provider.logoPath,
        availability: availability,
      );
    }

    return [
      ...regionData.flatrate.map((p) => mapProvider(p, StreamingAvailability.flatrate)),
      ...regionData.rent.map((p) => mapProvider(p, StreamingAvailability.rent)),
      ...regionData.buy.map((p) => mapProvider(p, StreamingAvailability.buy)),
    ];
  }

  static MovieDetailsEntity detailsToEntity(
    MovieDetailsModel model, {
    required String watchRegion,
  }) {
    return MovieDetailsEntity(
      movie: toEntity(model.movie),
      tagline: model.tagline,
      runtimeMinutes: model.runtimeMinutes,
      genres: model.genres,
      cast: model.cast.map(castToEntity).toList(),
      crew: model.crew.map(crewToEntity).toList(),
      streamingProviders: providersForRegion(model.watchProviders, watchRegion),
      watchRegion: watchRegion,
    );
  }
}
