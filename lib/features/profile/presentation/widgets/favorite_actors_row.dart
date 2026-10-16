import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/tmdb_image_url.dart';
import '../../../auth/domain/entities/favorite_actor_entity.dart';
import '../../../movies/presentation/pages/actor_details_page.dart';
import 'empty_favorite_slot.dart';

/// Quatro atores em círculo; vagas vazias convidam a escolher (se editável).
class FavoriteActorsRow extends StatelessWidget {
  const FavoriteActorsRow({super.key, required this.actors, this.onAdd});

  static const slots = 4;

  final List<FavoriteActorEntity> actors;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < slots; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: index < actors.length
                ? _ActorSlot(actor: actors[index])
                : AspectRatio(
                    aspectRatio: 1,
                    child: EmptyFavoriteSlot(onTap: onAdd, circular: true),
                  ),
          ),
        ],
      ],
    );
  }
}

class _ActorSlot extends StatelessWidget {
  const _ActorSlot({required this.actor});

  final FavoriteActorEntity actor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ActorDetailsPage(personId: actor.personId)),
        );
      },
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) => TuliAvatar(
              size: constraints.maxWidth,
              imageUrl: TmdbImageUrl.profile(actor.profilePath),
              initials: TuliRingAvatar.initials(actor.name),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            actor.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
