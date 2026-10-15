import 'package:cloud_firestore/cloud_firestore.dart';

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
    this.createdAt,
    this.read = false,
  });

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
      // Escrita local pendente ainda sem horário do servidor.
      createdAt: createdAt ?? DateTime.now(),
      read: read,
    );
  }
}
