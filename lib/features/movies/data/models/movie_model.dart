class MovieModel {
  const MovieModel({
    required this.id,
    required this.title,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage = 0,
    this.genreIds = const [],
  });

  final int id;
  final String title;
  final String? originalTitle;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final List<int> genreIds;

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      originalTitle: json['original_title'] as String? ?? json['original_name'] as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );
  }
}

class PaginatedMoviesModel {
  const PaginatedMoviesModel({
    required this.results,
    required this.page,
    required this.totalResults,
  });

  final List<MovieModel> results;
  final int page;
  final int totalResults;

  factory PaginatedMoviesModel.fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MovieModel.fromJson)
        .toList();

    return PaginatedMoviesModel(
      results: results,
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalResults: (json['total_results'] as num?)?.toInt() ?? results.length,
    );
  }
}
