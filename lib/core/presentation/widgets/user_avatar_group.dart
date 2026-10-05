import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Avatar único ou grupo sobreposto (sessões em grupo / feed).
class UserAvatarGroup extends StatelessWidget {
  const UserAvatarGroup({
    super.key,
    required this.imageUrls,
    this.initials,
    this.maxVisible = 4,
    this.size = 36,
    this.overlap = 10,
    this.onTap,
  }) : assert(
          imageUrls.length == initials?.length || initials == null,
          'initials deve ter o mesmo tamanho de imageUrls quando informado',
        );

  final List<String?> imageUrls;
  final List<String>? initials;
  final int maxVisible;
  final double size;
  final double overlap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return TuliAvatar(size: size, initials: '?');
    }

    if (imageUrls.length == 1) {
      return TuliAvatar(
        size: size,
        imageUrl: imageUrls.first,
        initials: initials?.first,
        onTap: onTap,
      );
    }

    final visible = imageUrls.take(maxVisible).toList();
    final extra = imageUrls.length - visible.length;
    final width = size + (visible.length - 1) * (size - overlap) + (extra > 0 ? size - overlap : 0);

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: TuliAvatar(
                size: size,
                imageUrl: visible[i],
                initials: initials != null ? initials![i] : _initialFromIndex(i),
                borderWidth: 2,
              ),
            ),
          if (extra > 0)
            Positioned(
              left: visible.length * (size - overlap),
              child: TuliAvatar(
                size: size,
                initials: '+$extra',
                backgroundColor: AppColors.surfaceMuted,
              ),
            ),
        ],
      ),
    );
  }

  String _initialFromIndex(int index) => String.fromCharCode(65 + (index % 26));
}

/// Avatar circular reutilizável (usado pelo grupo e isolado).
class TuliAvatar extends StatefulWidget {
  const TuliAvatar({
    super.key,
    this.size = 40,
    this.imageUrl,
    this.initials,
    this.backgroundColor,
    this.onTap,
    this.borderWidth = 0,
  });

  final double size;
  final String? imageUrl;
  final String? initials;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double borderWidth;

  @override
  State<TuliAvatar> createState() => _TuliAvatarState();
}

class _TuliAvatarState extends State<TuliAvatar> {
  bool _pressed = false;

  bool get _hasNetworkImage =>
      widget.imageUrl != null && widget.imageUrl!.trim().isNotEmpty;

  Widget _initialsText(String display) {
    return Center(
      child: Text(
        display,
        style: TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.w700,
          fontSize: widget.size * 0.36,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final letters = (widget.initials ?? '?').trim();
    final display = letters.length > 2 ? letters.substring(0, 2).toUpperCase() : letters.toUpperCase();

    final avatar = AnimatedScale(
      scale: _pressed ? 0.94 : 1,
      duration: AppDurations.fast,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.backgroundColor ?? AppColors.surfaceElevated,
          border: Border.all(
            color: AppColors.backgroundDeep,
            width: widget.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: _hasNetworkImage
            ? Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                width: widget.size,
                height: widget.size,
                errorBuilder: (_, __, ___) => _initialsText(display),
              )
            : _initialsText(display),
      ),
    );

    if (widget.onTap == null) return avatar;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: avatar,
    );
  }
}
