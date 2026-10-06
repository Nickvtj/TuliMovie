import '../../domain/entities/discover_query_entity.dart';

abstract final class DiscoverQueryBuilder {
  static Map<String, dynamic> toQueryParameters(DiscoverQueryEntity query) {
    final params = <String, dynamic>{
      'page': query.page,
      'language': query.language,
      'watch_region': query.watchRegion,
      'sort_by': query.sortBy,
      'include_adult': false,
      'include_video': false,
    };

    if (query.withWatchProviderIds.isNotEmpty) {
      params['with_watch_providers'] = query.withWatchProviderIds.join('|');
    }
    if (query.withGenres.isNotEmpty) {
      params['with_genres'] = query.withGenres.join(',');
    }
    if (query.primaryReleaseDateGte != null) {
      params['primary_release_date.gte'] = query.primaryReleaseDateGte;
    }
    if (query.primaryReleaseDateLte != null) {
      params['primary_release_date.lte'] = query.primaryReleaseDateLte;
    }
    if (query.runtimeLteMinutes != null) {
      params['with_runtime.lte'] = query.runtimeLteMinutes;
    }
    if (query.voteAverageGte != null) {
      params['vote_average.gte'] = query.voteAverageGte;
    }
    if (query.voteCountLte != null) {
      params['vote_count.lte'] = query.voteCountLte;
    } else if (query.voteAverageGte == null) {
      params['vote_count.gte'] = 50;
    }

    return params;
  }
}
