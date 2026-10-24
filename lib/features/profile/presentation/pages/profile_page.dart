import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/tmdb_image_url.dart';
import '../../../auth/domain/entities/favorite_movie_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../awards/presentation/pages/tuli_awards_page.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../../../feed/presentation/widgets/review_card_widget.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';
import '../../../movies/presentation/providers/movie_providers.dart';
import '../../../social/presentation/widgets/follow_stats_row.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/profile_dashboard_entity.dart';
import '../providers/profile_providers.dart';
import '../utils/profile_vibe_label.dart';
import '../widgets/favorite_actors_row.dart';
import '../widgets/favorite_movies_row.dart';
import 'edit_favorites_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

enum _ProfileTab { reviews, badges }

class _ProfilePageState extends ConsumerState<ProfilePage> {
  _ProfileTab _tab = _ProfileTab.reviews;

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _showMenu(UserEntity user) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppShape.radiusLg)),
      ),
      builder: (sheetContext) {
        void closeThen(VoidCallback action) {
          Navigator.of(sheetContext).pop();
          action();
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Editar perfil'),
                  onTap: () => closeThen(() => _push(EditProfilePage(user: user))),
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events_outlined, color: AppColors.gold),
                  title: const Text('Tuli Awards — sua retrospectiva'),
                  onTap: () => closeThen(() => _push(const TuliAwardsPage())),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.neonRed),
                  title: const Text('Sair da conta'),
                  onTap: () => closeThen(() => ref.read(signOutUseCaseProvider)()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider).valueOrNull;
    final dashboard = ref.watch(profileDashboardProvider);

    if (session == null) {
      return const Scaffold(body: Center(child: TuliFeedSkeleton(itemCount: 3)));
    }

    return dashboard.when(
      loading: () => const Scaffold(body: Center(child: TuliFeedSkeleton(itemCount: 4))),
      error: (_, __) => Scaffold(
        body: TuliEmptyState(
          message: 'Não foi possível carregar seu perfil.',
          icon: Icons.cloud_off_rounded,
          action: TuliButton(
            label: 'Tentar de novo',
            icon: Icons.refresh_rounded,
            onPressed: () => ref.invalidate(profileDashboardProvider),
          ),
        ),
      ),
      data: (data) => _buildProfile(session, data),
    );
  }

  Widget _buildProfile(UserEntity user, ProfileDashboardEntity data) {
    final textTheme = Theme.of(context).textTheme;

    // Top 4 escolhido pelo usuário; sem escolha, usa as maiores notas.
    final pickedMovies = user.favoriteMovies;
    final topMovies = pickedMovies.isNotEmpty
        ? pickedMovies
        : data.top4
            .map((slot) => FavoriteMovieEntity(
                  tmdbMovieId: slot.tmdbMovieId,
                  title: slot.title,
                  posterPath: slot.posterPath,
                ))
            .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHero(
              user: user,
              coverMovieId: topMovies.firstOrNull?.tmdbMovieId,
              onOpenMenu: () => _showMenu(user),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Column(
                children: [
                  Text(
                    user.displayName,
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (user.hasUsername)
                    Text(
                      '@${user.username}',
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  if (user.hasBio)
                    Text(
                      user.bio!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    )
                  else
                    TextButton.icon(
                      onPressed: () => _push(EditProfilePage(user: user)),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Adicionar uma bio'),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  _VibePill(label: data.cinephileLabel),
                  const SizedBox(height: AppSpacing.lg),
                  FollowStatsRow(userId: user.id),
                  const SizedBox(height: AppSpacing.lg),
                  TuliButton(
                    label: 'Editar perfil',
                    icon: Icons.edit_outlined,
                    variant: TuliButtonVariant.secondary,
                    expand: true,
                    onPressed: () => _push(EditProfilePage(user: user)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ProfileStatsStrip(data: data),
                  const SizedBox(height: AppSpacing.xl),
                  TuliSectionTitle(
                    title: 'Top 4 filmes',
                    actionLabel: 'Editar',
                    onAction: () => _push(
                      EditFavoritesPage.movies(userId: user.id, current: pickedMovies),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FavoriteMoviesRow(
                    movies: topMovies,
                    onAdd: () => _push(
                      EditFavoritesPage.movies(userId: user.id, current: pickedMovies),
                    ),
                  ),
                  if (pickedMovies.isEmpty && topMovies.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Baseado nas suas maiores notas — toque em Editar para escolher.',
                      style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  TuliSectionTitle(
                    title: 'Top 4 atores',
                    actionLabel: 'Editar',
                    onAction: () => _push(
                      EditFavoritesPage.actors(userId: user.id, current: user.favoriteActors),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FavoriteActorsRow(
                    actors: user.favoriteActors,
                    onAdd: () => _push(
                      EditFavoritesPage.actors(userId: user.id, current: user.favoriteActors),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _ProfileTabs(
                    selected: _tab,
                    reviewCount: data.totalReviews,
                    unlockedBadges: data.badges.where((b) => b.unlocked).length,
                    totalBadges: data.badges.length,
                    onSelected: (tab) => setState(() => _tab = tab),
                  ),
                ],
              ),
            ),
          ),
          if (_tab == _ProfileTab.reviews)
            _ReviewsSliver(data: data)
          else
            _BadgesSliver(badges: data.badges),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}

/// Capa + avatar sobreposto + menu. O avatar fica por último no Stack para
/// ser desenhado por cima da capa.
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.user,
    required this.coverMovieId,
    required this.onOpenMenu,
  });

  static const _coverHeight = 150.0;
  static const _avatarSize = 88.0;

  final UserEntity user;
  final int? coverMovieId;
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: topInset + _coverHeight + _avatarSize / 2,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
            height: topInset + _coverHeight,
            width: double.infinity,
            child: _ProfileCover(movieId: coverMovieId),
          ),
          Positioned(
            top: topInset + AppSpacing.sm,
            right: AppSpacing.md,
            child: TuliIconButtonCircle(
              icon: Icons.more_horiz_rounded,
              tooltip: 'Mais opções',
              size: 38,
              onPressed: onOpenMenu,
            ),
          ),
          Positioned(
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.backgroundDeep,
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: TuliRingAvatar(
                  displayName: user.displayName,
                  imageUrl: user.photoUrl,
                  size: _avatarSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCover extends ConsumerWidget {
  const _ProfileCover({required this.movieId});

  final int? movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = movieId;
    final backdropPath =
        id == null ? null : ref.watch(movieDetailsProvider(id)).valueOrNull?.movie.backdropPath;
    final coverUrl = TmdbImageUrl.backdrop(backdropPath);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (coverUrl != null)
          CachedNetworkImage(imageUrl: coverUrl, fit: BoxFit.cover)
        else
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surfaceElevated, AppColors.backgroundDeep],
              ),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.15),
                AppColors.backgroundDeep,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VibePill extends StatelessWidget {
  const _VibePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppShape.borderRadiusPill,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        profileVibeDisplay(label),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ProfileStatsStrip extends StatelessWidget {
  const _ProfileStatsStrip({required this.data});

  final ProfileDashboardEntity data;

  @override
  Widget build(BuildContext context) {
    final unlocked = data.badges.where((b) => b.unlocked).length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShape.borderRadiusMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                icon: Icons.schedule_rounded,
                label: 'Horas',
                value: '${data.filometerHours.toStringAsFixed(0)}h',
              ),
            ),
            Container(width: 1, height: 36, color: AppColors.borderSubtle),
            Expanded(
              child: _StatCell(
                icon: Icons.rate_review_outlined,
                label: 'Avaliações',
                value: '${data.totalReviews}',
              ),
            ),
            Container(width: 1, height: 36, color: AppColors.borderSubtle),
            Expanded(
              child: _StatCell(
                icon: Icons.emoji_events_outlined,
                label: 'Conquistas',
                value: '$unlocked',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(height: 4),
        Text(
          value,
          style:
              textTheme.titleMedium?.copyWith(color: AppColors.gold, fontWeight: FontWeight.w700),
        ),
        Text(label, style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}

/// Seletor "Avaliações | Conquistas" em formato de segmento.
class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({
    required this.selected,
    required this.reviewCount,
    required this.unlockedBadges,
    required this.totalBadges,
    required this.onSelected,
  });

  final _ProfileTab selected;
  final int reviewCount;
  final int unlockedBadges;
  final int totalBadges;
  final ValueChanged<_ProfileTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShape.borderRadiusPill,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Avaliações · $reviewCount',
            selected: selected == _ProfileTab.reviews,
            onTap: () => onSelected(_ProfileTab.reviews),
          ),
          _TabButton(
            label: 'Conquistas · $unlockedBadges/$totalBadges',
            selected: selected == _ProfileTab.badges,
            onTap: () => onSelected(_ProfileTab.badges),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.gold : Colors.transparent,
        borderRadius: AppShape.borderRadiusPill,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppShape.borderRadiusPill,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.backgroundDeep : AppColors.textSecondary,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewsSliver extends ConsumerWidget {
  const _ReviewsSliver({required this.data});

  final ProfileDashboardEntity data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.recentReviews.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: TuliEmptyState(
            message: 'Você ainda não avaliou filmes.\nUse o + para começar.',
            icon: Icons.rate_review_outlined,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList.separated(
        itemCount: data.recentReviews.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final review = data.recentReviews[index];
          return ReviewCardWidget(
            review: review,
            compact: true,
            onDelete: isMyReview(ref, review) ? () => deleteReview(ref, review) : null,
            onOpenMovie: (_) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MovieDetailsPage(movieId: review.tmdbMovieId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BadgesSliver extends StatelessWidget {
  const _BadgesSliver({required this.badges});

  final List<BadgeEntity> badges;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.05,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final badge = badges[index];
            return TuliCard(
              variant: badge.unlocked ? TuliCardVariant.goldAccent : TuliCardVariant.standard,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Opacity(
                opacity: badge.unlocked ? 1 : 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(badge.emoji, style: const TextStyle(fontSize: 28)),
                        const Spacer(),
                        Icon(
                          badge.unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                          size: 18,
                          color: badge.unlocked ? AppColors.gold : AppColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      badge.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        badge.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: badges.length,
        ),
      ),
    );
  }
}
