import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewParticipantModel {
  const ReviewParticipantModel({
    required this.userId,
    required this.displayName,
    required this.rating,
    this.photoUrl,
    this.hasSubmittedRating = true,
  });

  final String userId;
  final String displayName;
  final double rating;
  final String? photoUrl;
  final bool hasSubmittedRating;

  factory ReviewParticipantModel.fromJson(Map<String, dynamic> json) {
    return ReviewParticipantModel(
      userId: json['userId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      photoUrl: json['photoUrl'] as String?,
      hasSubmittedRating: json['hasSubmittedRating'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'rating': rating,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'hasSubmittedRating': hasSubmittedRating,
      };
}

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.tmdbMovieId,
    required this.movieTitle,
    this.moviePosterPath,
    this.movieReleaseYear,
    required this.participants,
    required this.groupAverageRating,
    this.comment,
    required this.createdAt,
    this.reactions = const {},
    this.containsSpoiler = false,
    this.authorAnswers = const {},
  });

  final String id;
  final int tmdbMovieId;
  final String movieTitle;
  final String? moviePosterPath;
  final int? movieReleaseYear;
  final List<ReviewParticipantModel> participants;
  final double groupAverageRating;
  final String? comment;
  final DateTime createdAt;
  final Map<String, List<String>> reactions;
  final bool containsSpoiler;
  final Map<String, double> authorAnswers;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final reactionsRaw = json['reactions'] as Map<String, dynamic>? ?? {};
    final reactions = <String, List<String>>{};
    reactionsRaw.forEach((key, value) {
      if (value is List) {
        reactions[key] = value.map((e) => e.toString()).toList();
      }
    });

    final participants = (json['participants'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ReviewParticipantModel.fromJson)
        .toList();

    return ReviewModel(
      id: json['id'] as String? ?? '',
      tmdbMovieId: (json['tmdbMovieId'] as num?)?.toInt() ?? 0,
      movieTitle: json['movieTitle'] as String? ?? '',
      moviePosterPath: json['moviePosterPath'] as String?,
      movieReleaseYear: (json['movieReleaseYear'] as num?)?.toInt(),
      participants: participants,
      groupAverageRating: (json['groupAverageRating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] as String?,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      reactions: reactions,
      containsSpoiler: json['containsSpoiler'] as bool? ?? false,
      authorAnswers: _parseAuthorAnswers(json['authorAnswers']),
    );
  }

  ReviewModel copyWithId(String id) {
    return ReviewModel(
      id: id,
      tmdbMovieId: tmdbMovieId,
      movieTitle: movieTitle,
      moviePosterPath: moviePosterPath,
      movieReleaseYear: movieReleaseYear,
      participants: participants,
      groupAverageRating: groupAverageRating,
      comment: comment,
      createdAt: createdAt,
      reactions: reactions,
      containsSpoiler: containsSpoiler,
      authorAnswers: authorAnswers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tmdbMovieId': tmdbMovieId,
      'movieTitle': movieTitle,
      if (moviePosterPath != null) 'moviePosterPath': moviePosterPath,
      if (movieReleaseYear != null) 'movieReleaseYear': movieReleaseYear,
      'participants': participants.map((p) => p.toJson()).toList(),
      'groupAverageRating': groupAverageRating,
      if (comment != null) 'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'reactions': reactions,
      'containsSpoiler': containsSpoiler,
      if (authorAnswers.isNotEmpty) 'authorAnswers': authorAnswers,
    };
  }

  static Map<String, double> _parseAuthorAnswers(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map(
      (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
