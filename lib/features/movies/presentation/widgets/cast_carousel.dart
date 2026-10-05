import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/tmdb_image_url.dart';
import '../../domain/entities/cast_member_entity.dart';

typedef CastMemberTap = void Function(CastMemberEntity member);

class CastCarousel extends StatelessWidget {
  const CastCarousel({
    super.key,
    required this.cast,
    required this.onTapMember,
  });

  final List<CastMemberEntity> cast;
  final CastMemberTap onTapMember;

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) {
      return Text('Elenco indisponível.', style: Theme.of(context).textTheme.bodyMedium);
    }

    final topCast = cast.take(15).toList();

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topCast.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final member = topCast[index];
          final photo = TmdbImageUrl.profile(member.profilePath);

          return GestureDetector(
            onTap: () => onTapMember(member),
            child: SizedBox(
              width: 84,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: AppShape.borderRadiusSm,
                    child: photo == null
                        ? Container(
                            width: 72,
                            height: 72,
                            color: AppColors.surfaceMuted,
                            child: const Icon(Icons.person, color: AppColors.textMuted),
                          )
                        : CachedNetworkImage(
                            imageUrl: photo,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            memCacheWidth: 144,
                            placeholder: (_, __) => Container(
                              width: 72,
                              height: 72,
                              color: AppColors.surfaceMuted,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 72,
                              height: 72,
                              color: AppColors.surfaceMuted,
                              child: const Icon(Icons.person, color: AppColors.textMuted),
                            ),
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    member.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
