import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel {
  const NotificationModel({
    this.id = '',
    required this.recipientId,
    required this.type,
    required this.actorId,
    required this.actorName,
    this.actorPhotoUrl,
    this.reviewId,
    this.movieTitle,
    this.text,
    this.roomId,
    this.createdAt,
    this.read = false,
  });

  /// Aviso novo em nome de [actor] (quem seguiu, comentou ou convidou).
  factory NotificationModel.fromActor({
    required String recipientId,
    required NotificationType type,
    required UserEntity actor,
    String? reviewId,
    String? movieTitle,
    String? text,
    String? roomId,
  }) {
    return NotificationModel(
      recipientId: recipientId,
      type: type,
      actorId: actor.id,
      actorName: actor.displayName,
      actorPhotoUrl: actor.photoUrl,
      reviewId: reviewId,
      movieTitle: movieTitle,
      text: text,
      roomId: roomId,
    );
  }

  final String id;

  /// Dono da caixa de entrada — define o caminho, não é gravado no documento.
  final String recipientId;
  final NotificationType type;
  final String actorId;
  final String actorName;
  final String? actorPhotoUrl;
  final String? reviewId;
  final String? movieTitle;
  final String? text;
  final String? roomId;
  final DateTime? createdAt;
  final bool read;

  factory NotificationModel.fromJson(String recipientId, Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      recipientId: recipientId,
      type: NotificationType.values.asNameMap()[json['type']] ?? NotificationType.follow,
      actorId: json['actorId'] as String? ?? '',
      actorName: json['actorName'] as String? ?? '',
      actorPhotoUrl: json['actorPhotoUrl'] as String?,
      reviewId: json['reviewId'] as String?,
      movieTitle: json['movieTitle'] as String?,
      text: json['text'] as String?,
      roomId: json['roomId'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      read: json['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'actorId': actorId,
      'actorName': actorName,
      if (actorPhotoUrl != null) 'actorPhotoUrl': actorPhotoUrl,
      if (reviewId != null) 'reviewId': reviewId,
      if (movieTitle != null) 'movieTitle': movieTitle,
      if (text != null) 'text': text,
      if (roomId != null) 'roomId': roomId,
      'createdAt': FieldValue.serverTimestamp(),
      'read': read,
    };
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      type: type,
      actorId: actorId,
      actorName: actorName,
      actorPhotoUrl: actorPhotoUrl,
      reviewId: reviewId,
      movieTitle: movieTitle,
      text: text,
      roomId: roomId,
      // Escrita local pendente ainda sem horário do servidor.
      createdAt: createdAt ?? DateTime.now(),
      read: read,
    );
  }
}
