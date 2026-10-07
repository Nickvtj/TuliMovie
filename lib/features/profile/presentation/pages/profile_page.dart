import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iterable_extensions.dart';
import '../../../../core/utils/relative_time_pt.dart';
import '../../../../core/utils/tmdb_image_url.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../awards/presentation/pages/tuli_awards_page.dart';
import '../../../feed/domain/entities/review_entity.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';
import '../../../movies/presentation/providers/movie_providers.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/profile_dashboard_entity.dart';
import '../providers/profile_providers.dart';
import '../utils/profile_vibe_label.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

enum _ProfileSection { reviews, badges, more }

class _ProfilePageState extends ConsumerState<ProfilePage> {
  _ProfileSection _section = _ProfileSection.reviews;

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(profileDashboardProvider);
    final user = ref.watch(authSessionProvider).valueOrNull;

    return dashboard.when(
      loading: () => const Scaffold(body: Center(child: TuliFeedSkeleton(itemCount: 4))),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro no perfil: $e'))),
      data: (data) {
        final favoriteMovieId = data.top4.isNotEmpty ? data.top4.first.tmdbMovieId : null;
        final backdropAsync = favoriteMovieId == null
            ? null
            : ref.watch(movieDetailsProvider(favoriteMovieId));

        final backdropPath = backdropAsync?.valueOrNull?.movie.backdropPath;
        final posterFallback = data.top4.isNotEmpty ? data.top4.first.posterPath : null;
        final coverUrl = TmdbImageUrl.backdrop(backdropPath) ?? TmdbImageUrl.poster(posterFallback);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.backgroundDeep,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (coverUrl != null)
                        CachedNetworkImage(imageUrl: coverUrl, fit: BoxFit.cover)
                      else
                        const ColoredBox(color: AppColors.surface),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.2),
                              AppColors.backgroundDeep.withValues(alpha: 0.95),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                  child: Column(
                    children: [
                      TuliRingAvatar(
                        displayName: data.displayName,
                        imageUrl: user?.photoUrl,
                        size: 80,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(data.displayName, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: AppShape.borderRadiusPill,
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          profileVibeDisplay(data.cinephileLabel),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _ProfileStatsStrip(data: data)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                  child: Text('Top 4 da vida', style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _Top4Grid(top4: data.top4),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.section,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      TuliFilterChip(
                        label: 'Reviews',
                        selected: _section == _ProfileSection.reviews,
                        onSelected: () => setState(() => _section = _ProfileSection.reviews),
                      ),
                      TuliFilterChip(
                        label: 'Conquistas',
                        selected: _section == _ProfileSection.badges,
                        onSelected: () => setState(() => _section = _ProfileSection.badges),
                      ),
                      TuliFilterChip(
                        label: 'Mais',
                        selected: _section == _ProfileSection.more,
                        onSelected: () => setState(() => _section = _ProfileSection.more),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Divider(height: 1, color: AppColors.borderSubtle),
              ),
              ..._ProfileSectionContent.sliversFor(
                context: context,
                section: _section,
                reviews: data.recentReviews,
                userId: user?.id,
                badges: data.badges,
                onSignOut: () => ref.read(signOutUseCaseProvider)(),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileStatsStrip extends StatelessWidget {
  const _ProfileStatsStrip({required this.data});

  final ProfileDashboardEntity data;

  @override
  Widget build(BuildContext context) {
    final unlocked = data.badges.where((b) => b.unlocked).length;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: DecoratedBox(
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
                  label: 'Horas',
                  value: '${data.filometerHours.toStringAsFixed(0)}h',
                  textTheme: textTheme,
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.borderSubtle),
              Expanded(
                child: _StatCell(
                  label: 'Reviews',
                  value: '${data.totalReviews}',
                  textTheme: textTheme,
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.borderSubtle),
              Expanded(
                child: _StatCell(
                  label: 'Conquistas',
                  value: '$unlocked',
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: textTheme.titleMedium?.copyWith(color: AppColors.gold, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}

class _Top4Grid extends StatelessWidget {
  const _Top4Grid({required this.top4});

  final List<TopMovieSlotEntity> top4;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.68,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        if (index >= top4.length) {
          return _EmptyFavoriteSlot(index: index + 1);
        }
        final slot = top4[index];
        return TuliCard(
          padding: const EdgeInsets.all(8),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MovieDetailsPage(movieId: slot.tmdbMovieId),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TuliPosterImage(
                  posterPath: slot.posterPath,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                slot.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium,
              ),
              Text(
                '${slot.userRating.toStringAsFixed(1)}★',
                style: textTheme.labelSmall?.copyWith(color: AppColors.gold),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyFavoriteSlot extends StatelessWidget {
  const _EmptyFavoriteSlot({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(
        color: AppColors.borderElevated,
        radius: AppShape.borderRadiusMd.topLeft.x,
      ),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: AppShape.borderRadiusMd,
          color: AppColors.surfaceElevated.withValues(alpha: 0.4),
        ),
        child: Text(
          '+ Avalie mais filmes',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const dash = 6.0;
    const gap = 4.0;
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _ProfileSectionContent {
  static List<Widget> sliversFor({
    required BuildContext context,
    required _ProfileSection section,
    required List<ReviewEntity> reviews,
    required String? userId,
    required List<BadgeEntity> badges,
    required VoidCallback onSignOut,
  }) {
    switch (section) {
      case _ProfileSection.reviews:
        if (reviews.isEmpty) {
          return [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: TuliEmptyState(message: 'Você ainda não avaliou filmes.\nUse o + para começar.'),
              ),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList.separated(
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final review = reviews[index];
                final rating = review.participants
                    .where((p) => p.userId == userId)
                    .map((p) => p.rating)
                    .firstOrNull;

                return TuliCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MovieDetailsPage(movieId: review.tmdbMovieId),
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.movieTitle, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        formatRelativeTimePt(review.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                      if (rating != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Sua nota: ${rating.toStringAsFixed(1)}★',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.gold),
                        ),
                      ],
                      if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        TuliQuoteBlock(text: review.comment!, maxLines: 3),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ];
      case _ProfileSection.badges:
        return [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final badge = badges[index];
                  return TuliCard(
                    variant: badge.unlocked ? TuliCardVariant.goldAccent : TuliCardVariant.standard,
                    child: Opacity(
                      opacity: badge.unlocked ? 1 : 0.45,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${badge.emoji} ${badge.title}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(badge.description, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  );
                },
                childCount: badges.length,
              ),
            ),
          ),
        ];
      case _ProfileSection.more:
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  TuliButton(
                    label: 'Abrir Tuli Awards',
                    icon: Icons.emoji_events_outlined,
                    expand: true,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const TuliAwardsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TuliButton(
                    label: 'Sair da conta',
                    icon: Icons.logout_rounded,
                    expand: true,
                    variant: TuliButtonVariant.ghost,
                    onPressed: onSignOut,
                  ),
                ],
              ),
            ),
          ),
        ];
    }
  }
}
