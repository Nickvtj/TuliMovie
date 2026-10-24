import 'package:equatable/equatable.dart';

import '../../../movies/domain/entities/discover_query_entity.dart';

class MatchFiltersEntity extends Equatable {
  const MatchFiltersEntity({
    this.withWatchProviderIds = const [],
    this.maxRuntimeMinutes,
    this.genreIds = const [],
    this.releaseYearFrom,
    this.releaseYearTo,
    this.includeWatchlist = false,
  });

  /// Legado (sala antiga no Firestore).
  final List<int> withWatchProviderIds;
  final int? maxRuntimeMinutes;
  final List<int> genreIds;
  final int? releaseYearFrom;
  final int? releaseYearTo;
  /// Inclui filmes da watchlist pessoal do host.
  final bool includeWatchlist;

  int? get withWatchProviderId =>
      withWatchProviderIds.isEmpty ? null : withWatchProviderIds.first;

  int? get genreId => genreIds.isEmpty ? null : genreIds.first;

  DiscoverQueryEntity toDiscoverQuery({required int page}) {
    return DiscoverQueryEntity(
      page: page,
      withWatchProviderIds: withWatchProviderIds,
      withGenres: genreIds,
      primaryReleaseDateGte:
          releaseYearFrom == null ? null : '$releaseYearFrom-01-01',
      primaryReleaseDateLte:
          releaseYearTo == null ? null : '$releaseYearTo-12-31',
      runtimeLteMinutes: maxRuntimeMinutes,
      // Mais votados primeiro: clássicos conhecidos → menos avaliados.
      sortBy: 'vote_count.desc',
    );
  }

  @override
  List<Object?> get props => [
        withWatchProviderIds,
        maxRuntimeMinutes,
        genreIds,
        releaseYearFrom,
        releaseYearTo,
        includeWatchlist,
      ];
}
