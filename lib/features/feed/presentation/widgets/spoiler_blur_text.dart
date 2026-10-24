import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_effects.dart';
import '../../../../core/theme/app_theme.dart';

/// Comentário com spoiler — blur até o usuário tocar para revelar.
class SpoilerBlurText extends StatefulWidget {
  const SpoilerBlurText({
    super.key,
    required this.text,
    this.maxLines = 3,
  });

  final String text;
  final int maxLines;

  @override
  State<SpoilerBlurText> createState() => _SpoilerBlurTextState();
}

class _SpoilerBlurTextState extends State<SpoilerBlurText> {
  bool _revealed = false;

  Widget _cover(BuildContext context, {required double opacity}) {
    return Container(
      color: AppColors.surfaceMuted.withValues(alpha: opacity),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        'Contém spoiler — toque para ver',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.neonRed,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_revealed) {
      return Text(widget.text, style: Theme.of(context).textTheme.bodyMedium);
    }

    return GestureDetector(
      onTap: () => setState(() => _revealed = true),
      child: Stack(
        children: [
          Text(
            widget.text,
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: AppShape.borderRadiusSm,
              // No iPhone o desfoque ao vivo de cada card trava a rolagem do
              // feed: lá o texto fica coberto por uma tarja sólida.
              child: AppEffects.reduced
                  ? _cover(context, opacity: 0.97)
                  : BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: _cover(context, opacity: 0.35),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
