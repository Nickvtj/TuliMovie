import 'package:equatable/equatable.dart';

class BadgeEntity extends Equatable {
  const BadgeEntity({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String emoji;
  final String description;
  final bool unlocked;

  @override
  List<Object?> get props => [id, title, emoji, description, unlocked];
}
