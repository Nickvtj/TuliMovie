import 'package:equatable/equatable.dart';

class MatchFiltersEntity extends Equatable {
  const MatchFiltersEntity({
    this.withWatchProviderId,
    this.maxRuntimeMinutes,
    this.genreId,
  });

  final int? withWatchProviderId;
  final int? maxRuntimeMinutes;
  final int? genreId;

  @override
  List<Object?> get props => [withWatchProviderId, maxRuntimeMinutes, genreId];
}
