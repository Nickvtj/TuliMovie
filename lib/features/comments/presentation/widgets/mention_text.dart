import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../social/presentation/pages/user_profile_page.dart';
import '../../domain/utils/mention_parser.dart';

/// Texto com `@usuario` em destaque; menções resolvidas abrem o perfil.
class MentionText extends StatefulWidget {
  const MentionText({super.key, required this.text, this.mentions = const {}, this.style});

  final String text;

  /// username → userId.
  final Map<String, String> mentions;
  final TextStyle? style;

  @override
  State<MentionText> createState() => _MentionTextState();
}

class _MentionTextState extends State<MentionText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer? _recognizerFor(String? userId) {
    if (userId == null) return null;
    final recognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => UserProfilePage(userId: userId)),
        );
      };
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();

    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in MentionParser.pattern.allMatches(widget.text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: widget.text.substring(cursor, match.start)));
      }
      final userId = widget.mentions[match.group(1)!.toLowerCase()];
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(
            color: userId == null ? null : AppColors.gold,
            fontWeight: userId == null ? null : FontWeight.w600,
          ),
          recognizer: _recognizerFor(userId),
        ),
      );
      cursor = match.end;
    }
    if (cursor < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(cursor)));
    }

    return Text.rich(
      TextSpan(style: widget.style ?? Theme.of(context).textTheme.bodyMedium, children: spans),
    );
  }
}
