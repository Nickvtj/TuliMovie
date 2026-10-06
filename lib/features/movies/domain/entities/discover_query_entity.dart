import 'package:equatable/equatable.dart';

/// Parâmetros unificados para `/discover/movie` (Descubra + Match).
class DiscoverQueryEntity extends Equatable {
  const DiscoverQueryEntity({
    this.page = 1,
    this.language = 'pt-BR',
    this.watchRegion = 'BR',
    this.withWatchProviderIds = const [],
    this.withGenres = const [],
    this.primaryReleaseDateGte,
    this.primaryReleaseDateLte,
    this.runtimeLteMinutes,
    this.voteAverageGte,
    this.voteCountLte,
    this.sortBy = 'popularity.desc',
  });

  final int page;
  final String language;
  final String watchRegion;
  final List<int> withWatchProviderIds;
  final List<int> withGenres;
  final String? primaryReleaseDateGte;
  final String? primaryReleaseDateLte;
  final int? runtimeLteMinutes;
  final double? voteAverageGte;
  final int? voteCountLte;
  final String sortBy;

  DiscoverQueryEntity copyWith({
    int? page,
    String? language,
    String? watchRegion,
    List<int>? withWatchProviderIds,
    List<int>? withGenres,
    String? primaryReleaseDateGte,
    String? primaryReleaseDateLte,
    int? runtimeLteMinutes,
    double? voteAverageGte,
    int? voteCountLte,
    String? sortBy,
  }) {
    return DiscoverQueryEntity(
      page: page ?? this.page,
      language: language ?? this.language,
      watchRegion: watchRegion ?? this.watchRegion,
      withWatchProviderIds: withWatchProviderIds ?? this.withWatchProviderIds,
      withGenres: withGenres ?? this.withGenres,
      primaryReleaseDateGte: primaryReleaseDateGte ?? this.primaryReleaseDateGte,
      primaryReleaseDateLte: primaryReleaseDateLte ?? this.primaryReleaseDateLte,
      runtimeLteMinutes: runtimeLteMinutes ?? this.runtimeLteMinutes,
      voteAverageGte: voteAverageGte ?? this.voteAverageGte,
      voteCountLte: voteCountLte ?? this.voteCountLte,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [
        page,
        language,
        watchRegion,
        withWatchProviderIds,
        withGenres,
        primaryReleaseDateGte,
        primaryReleaseDateLte,
        runtimeLteMinutes,
        voteAverageGte,
        voteCountLte,
        sortBy,
      ];
}
