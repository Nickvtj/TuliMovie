import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Seletor/visualizador de estrelas (0–5, passo 0.5 opcional).
class TuliRatingStars extends StatelessWidget {
  const TuliRatingStars({
    super.key,
    required this.value,
    this.onChanged,
    this.maxStars = 5,
    this.starSize = 28,
    this.allowHalfStars = false,
    this.readOnly = false,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final int maxStars;
  final double starSize;
  final bool allowHalfStars;
  final bool readOnly;

  bool get _interactive => onChanged != null && !readOnly;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Nota ${value.toStringAsFixed(1)} de $maxStars estrelas',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxStars, (index) {
          final starIndex = index + 1;
          final fill = _fillAmountForStar(starIndex);

          return _StarTile(
            fill: fill,
            size: starSize,
            interactive: _interactive,
            onTap: () => _handleTap(starIndex),
            onHalfTap: allowHalfStars
                ? () => onChanged?.call(starIndex - 0.5)
                : null,
          );
        }),
      ),
    );
  }

  double _fillAmountForStar(int starIndex) {
    if (value >= starIndex) return 1;
    if (allowHalfStars && value >= starIndex - 0.5) return 0.5;
    return 0;
  }

  void _handleTap(int starIndex) {
    if (!_interactive) return;
    if (allowHalfStars) {
      onChanged!(starIndex.toDouble());
    } else {
      onChanged!(starIndex.toDouble());
    }
  }
}

class _StarTile extends StatefulWidget {
  const _StarTile({
    required this.fill,
    required this.size,
    required this.interactive,
    this.onTap,
    this.onHalfTap,
  });

  final double fill;
  final double size;
  final bool interactive;
  final VoidCallback? onTap;
  final VoidCallback? onHalfTap;

  @override
  State<_StarTile> createState() => _StarTileState();
}

class _StarTileState extends State<_StarTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final star = AnimatedScale(
      scale: _pressed ? 1.15 : 1,
      duration: AppDurations.fast,
      curve: Curves.easeOutBack,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.star_rounded,
              size: widget.size,
              color: AppColors.starEmpty,
            ),
            ClipRect(
              clipper: _HorizontalClipper(widget.fill),
              child: Icon(
                Icons.star_rounded,
                size: widget.size,
                color: AppColors.starFilled,
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.interactive) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: star,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        onLongPress: widget.onHalfTap,
        child: star,
      ),
    );
  }
}

class _HorizontalClipper extends CustomClipper<Rect> {
  _HorizontalClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fraction.clamp(0, 1), size.height);
  }

  @override
  bool shouldReclip(_HorizontalClipper oldClipper) =>
      oldClipper.fraction != fraction;
}
