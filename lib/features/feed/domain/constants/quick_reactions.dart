import 'package:equatable/equatable.dart';

class QuickReactionOption extends Equatable {
  const QuickReactionOption({
    required this.key,
    required this.emoji,
    required this.label,
  });

  final String key;
  final String emoji;
  final String label;

  @override
  List<Object?> get props => [key, emoji, label];
}

abstract final class QuickReactions {
  static const options = [
    QuickReactionOption(key: 'sleep', emoji: '😴', label: 'Dormi na metade'),
    QuickReactionOption(key: 'cry', emoji: '😭', label: 'Chorei de verdade'),
    QuickReactionOption(key: 'pure', emoji: '🎬', label: 'Cinema Puro'),
    QuickReactionOption(key: 'blame', emoji: '🌽', label: 'Quem escolheu isso?'),
  ];

  static QuickReactionOption? byKey(String key) {
    for (final option in options) {
      if (option.key == key) return option;
    }
    return null;
  }
}
