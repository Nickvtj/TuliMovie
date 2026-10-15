import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  const CommentEntity({
    required this.id,
    required this.reviewId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.text,
    this.mentions = const {},
    required this.createdAt,
  });

  final String id;
  final String reviewId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;

  /// username → userId das pessoas mencionadas no texto.
  final Map<String, String> mentions;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        reviewId,
        authorId,
        authorName,
        authorPhotoUrl,
        text,
        mentions,
        createdAt,
      ];
}
