import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/favorite_actor_entity.dart';
import '../../domain/entities/favorite_movie_entity.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.username,
    this.photoUrl,
    this.bio,
    this.favoriteMovies = const [],
    this.favoriteActors = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  /// Só em memória (vem do Firebase Auth) — perfil público não grava e-mail.
  final String email;
  final String displayName;
  final String? username;
  final String? photoUrl;
  final String? bio;
  final List<FavoriteMovieEntity> favoriteMovies;
  final List<FavoriteActorEntity> favoriteActors;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      username: json['username'] as String?,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      favoriteMovies: _parseList(json['favoriteMovies'], _movieFromJson),
      favoriteActors: _parseList(json['favoriteActors'], _actorFromJson),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  /// Usado na criação/bootstrap do perfil. Bio e favoritos só mudam por
  /// [profileUpdateJson], para um merge nunca apagar o que o usuário editou.
  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'displayNameLower': displayName.trim().toLowerCase(),
      if (username != null) 'username': username,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Campos editáveis do perfil; só inclui o que foi informado.
  static Map<String, dynamic> profileUpdateJson({
    String? displayName,
    String? bio,
    String? photoUrl,
    List<FavoriteMovieEntity>? favoriteMovies,
    List<FavoriteActorEntity>? favoriteActors,
  }) {
    return {
      if (displayName != null) ...{
        'displayName': displayName,
        'displayNameLower': displayName.trim().toLowerCase(),
      },
      if (bio != null) 'bio': bio,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (favoriteMovies != null) 'favoriteMovies': favoriteMovies.map(_movieToJson).toList(),
      if (favoriteActors != null) 'favoriteActors': favoriteActors.map(_actorToJson).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio,
      favoriteMovies: favoriteMovies,
      favoriteActors: favoriteActors,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static FavoriteMovieEntity _movieFromJson(Map<String, dynamic> json) {
    return FavoriteMovieEntity(
      tmdbMovieId: (json['tmdbMovieId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      posterPath: json['posterPath'] as String?,
    );
  }

  static Map<String, dynamic> _movieToJson(FavoriteMovieEntity movie) => {
        'tmdbMovieId': movie.tmdbMovieId,
        'title': movie.title,
        if (movie.posterPath != null) 'posterPath': movie.posterPath,
      };

  static FavoriteActorEntity _actorFromJson(Map<String, dynamic> json) {
    return FavoriteActorEntity(
      personId: (json['personId'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      profilePath: json['profilePath'] as String?,
    );
  }

  static Map<String, dynamic> _actorToJson(FavoriteActorEntity actor) => {
        'personId': actor.personId,
        'name': actor.name,
        if (actor.profilePath != null) 'profilePath': actor.profilePath,
      };

  static List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
