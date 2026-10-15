import 'package:equatable/equatable.dart';

class AwardsTopMovieEntity extends Equatable {
  const AwardsTopMovieEntity({
    required this.tmdbMovieId,
    required this.title,
    this.posterPath,
    required this.averageRating,
    required this.reviewCount,
  });

  final int tmdbMovieId;
  final String title;
  final String? posterPath;

  /// Nota do usuário (média se avaliou o mesmo filme mais de uma vez).
  final double averageRating;
  final int reviewCount;

  @override
  List<Object?> get props => [tmdbMovieId, title, posterPath, averageRating, reviewCount];
}

/// Amigo marcado como "assistiu com" nas avaliações do ano.
class AwardsCompanionEntity extends Equatable {
  const AwardsCompanionEntity({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.sessionCount,
  });

  final String userId;
  final String displayName;
  final String? photoUrl;
  final int sessionCount;

  @override
  List<Object?> get props => [userId, displayName, photoUrl, sessionCount];
}

class ComicCategoryEntity extends Equatable {
  const ComicCategoryEntity({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;

  @override
  List<Object?> get props => [id, title, subtitle];
}

/// Retrospectiva pessoal do ano.
class TuliAwardsEntity extends Equatable {
  const TuliAwardsEntity({
    required this.year,
    required this.totalMovies,
    required this.totalHoursEstimate,
    required this.topMovies,
    this.averageRating,
    required this.companions,
    required this.categories,
  });

  final int year;
  final int totalMovies;
  final double totalHoursEstimate;
  final List<AwardsTopMovieEntity> topMovies;

  /// Média das notas do usuário no ano; `null` sem avaliações.
  final double? averageRating;

  /// Quem mais assistiu com o usuário, do maior para o menor.
  final List<AwardsCompanionEntity> companions;
  final List<ComicCategoryEntity> categories;

  @override
  List<Object?> get props => [
        year,
        totalMovies,
        totalHoursEstimate,
        topMovies,
        averageRating,
        companions,
        categories,
      ];
}
