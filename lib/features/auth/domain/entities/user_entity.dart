import 'package:equatable/equatable.dart';

import 'favorite_actor_entity.dart';
import 'favorite_movie_entity.dart';

class UserEntity extends Equatable {
  const UserEntity({
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
  final String email;
  final String displayName;
  final String? username;
  final String? photoUrl;
  final String? bio;
  final List<FavoriteMovieEntity> favoriteMovies;
  final List<FavoriteActorEntity> favoriteActors;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasUsername => username != null && username!.isNotEmpty;

  bool get hasBio => bio != null && bio!.trim().isNotEmpty;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final name = parts.first;
      return (name.length >= 2 ? name.substring(0, 2) : name).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        username,
        photoUrl,
        bio,
        favoriteMovies,
        favoriteActors,
        createdAt,
        updatedAt,
      ];
}
