import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/comment_entity.dart';

class CommentModel {
  const CommentModel({
    this.id = '',
    required this.reviewId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.text,
    this.mentions = const {},
    this.createdAt,
  });

  final String id;

  /// Define o caminho (`reviews/{reviewId}/comments`), não é gravado no documento.
  final String reviewId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;
  final Map<String, String> mentions;
  final DateTime? createdAt;

  factory CommentModel.fromJson(String reviewId, Map<String, dynamic> json) {
    final mentionsRaw = json['mentions'] as Map<String, dynamic>? ?? {};
    return CommentModel(
      id: json['id'] as String? ?? '',
      reviewId: reviewId,
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorPhotoUrl: json['authorPhotoUrl'] as String?,
      text: json['text'] as String? ?? '',
      mentions: mentionsRaw.map((key, value) => MapEntry(key, value.toString())),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      if (authorPhotoUrl != null) 'authorPhotoUrl': authorPhotoUrl,
      'text': text,
      if (mentions.isNotEmpty) 'mentions': mentions,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      reviewId: reviewId,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      text: text,
      mentions: mentions,
      // Escrita local pendente ainda sem horário do servidor.
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}
