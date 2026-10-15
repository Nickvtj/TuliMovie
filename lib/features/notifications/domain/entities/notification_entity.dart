import 'package:equatable/equatable.dart';

enum NotificationType { follow, comment, mention }

/// Aviso dentro do app (`users/{uid}/notifications`).
class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.type,
    required this.actorId,
    required this.actorName,
    this.actorPhotoUrl,
    this.reviewId,
    this.movieTitle,
    this.text,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final NotificationType type;
  final String actorId;
  final String actorName;
  final String? actorPhotoUrl;

  /// Post relacionado (comentário / menção).
  final String? reviewId;
  final String? movieTitle;

  /// Trecho do comentário.
  final String? text;
  final DateTime createdAt;
  final bool read;

  @override
  List<Object?> get props => [
        id,
        type,
        actorId,
        actorName,
        actorPhotoUrl,
        reviewId,
        movieTitle,
        text,
        createdAt,
        read,
      ];
}
