import 'package:equatable/equatable.dart';

import '../../../movies/domain/constants/tmdb_genres.dart';
import '../../../movies/domain/entities/discover_query_entity.dart';

/// Filtros da aba Descubra (gênero principal + avançados).
class DiscoverFilterEntity extends Equatable {
  const DiscoverFilterEntity({
    this.primaryGenreId,
    this.withWatchProviderIds = const [],
    this.releaseYearFrom,
    this.releaseYearTo,
    this.minVoteAverage,
    this.runtimeLteMinutes,
  });

  /// Gênero do chip horizontal (`null` = Todos).
  final int? primaryGenreId;
  final List<int> withWatchProviderIds;
  final int? releaseYearFrom;
  final int? releaseYearTo;
  final double? minVoteAverage;
  final int? runtimeLteMinutes;

  bool get hasAdvancedFilters =>
      withWatchProviderIds.isNotEmpty ||
      releaseYearFrom != null ||
      releaseYearTo != null ||
      minVoteAverage != null ||
      runtimeLteMinutes != null;

  bool get usesMixedFeed => primaryGenreId == null && !hasAdvancedFilters;

  String get primaryGenreLabel {
    if (primaryGenreId == null) return 'Todos';
    return TmdbGenres.labelFor(primaryGenreId!) ?? 'Gênero';
  }

  DiscoverFilterEntity copyWith({
    int? primaryGenreId,
    bool clearPrimaryGenre = false,
    List<int>? withWatchProviderIds,
    int? releaseYearFrom,
    int? releaseYearTo,
    double? minVoteAverage,
    int? runtimeLteMinutes,
    bool clearAdvanced = false,
  }) {
    if (clearAdvanced) {
      return DiscoverFilterEntity(
        primaryGenreId: clearPrimaryGenre ? null : this.primaryGenreId,
      );
    }
    return DiscoverFilterEntity(
      primaryGenreId: clearPrimaryGenre
          ? null
          : (primaryGenreId != null ? primaryGenreId : this.primaryGenreId),
      withWatchProviderIds: withWatchProviderIds ?? this.withWatchProviderIds,
      releaseYearFrom: releaseYearFrom ?? this.releaseYearFrom,
      releaseYearTo: releaseYearTo ?? this.releaseYearTo,
      minVoteAverage: minVoteAverage ?? this.minVoteAverage,
      runtimeLteMinutes: runtimeLteMinutes ?? this.runtimeLteMinutes,
    );
  }

  DiscoverQueryEntity toDiscoverQuery({required int page}) {
    return DiscoverQueryEntity(
      page: page,
      withWatchProviderIds: withWatchProviderIds,
      withGenres: primaryGenreId == null ? const [] : [primaryGenreId!],
      primaryReleaseDateGte: _dateGte(releaseYearFrom),
      primaryReleaseDateLte: _dateLte(releaseYearTo),
      runtimeLteMinutes: runtimeLteMinutes,
      voteAverageGte: minVoteAverage,
      sortBy: primaryGenreId == null && minVoteAverage != null
          ? 'vote_average.desc'
          : 'popularity.desc',
    );
  }

  static String? _dateGte(int? year) => year == null ? null : '$year-01-01';
  static String? _dateLte(int? year) => year == null ? null : '$year-12-31';

  @override
  List<Object?> get props => [
        primaryGenreId,
        withWatchProviderIds,
        releaseYearFrom,
        releaseYearTo,
        minVoteAverage,
        runtimeLteMinutes,
      ];
}

abstract final class DiscoverFilterDefaults {
  static int get currentYear => DateTime.now().year;
}
