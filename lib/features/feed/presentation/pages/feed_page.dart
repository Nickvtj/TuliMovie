import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../share/presentation/providers/share_providers.dart';
import '../../../social/presentation/pages/user_search_page.dart';
import '../providers/feed_providers.dart';
import '../providers/feed_read_providers.dart';
import '../widgets/review_card_widget.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(feedNotifierProvider.notifier).loadInitial());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (offset >= max - 280) {
      ref.read(feedNotifierProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedNotifierProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async {
          await ref.read(feedNotifierProvider.notifier).refresh();
          markFeedAsSeen(ref);
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              toolbarHeight: 84,
              titleSpacing: AppSpacing.lg,
              backgroundColor: AppColors.backgroundDeep,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              title: const _FeedTitle(),
              actions: [
                const _NotificationsButton(),
                const SizedBox(width: AppSpacing.sm),
                TuliIconButtonCircle(
                  icon: Icons.person_search_rounded,
                  tooltip: 'Buscar pessoas',
                  size: _headerActionSize,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const UserSearchPage()),
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.lg),
              ],
            ),
            if (feed.isInitialLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: TuliFeedSkeleton(itemCount: 4),
                ),
              )
            else if (feed.reviews.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: TuliEmptyState(
                  message: feed.errorMessage ??
                      'Seu feed está vazio.\nSiga pessoas pela lupa ou toque no + para avaliar!',
                  icon: Icons.dynamic_feed_outlined,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                sliver: SliverList.separated(
                  itemCount: feed.reviews.length + (feed.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    if (index >= feed.reviews.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final review = feed.reviews[index];
                    return ReviewCardWidget(
                      review: review,
                      onCommentsClosed: () =>
                          ref.read(feedNotifierProvider.notifier).reloadReview(review.id),
                      onDelete: isMyReview(ref, review) ? () => deleteReview(ref, review) : null,
                      onShare: () async {
                        try {
                          await ref.read(shareReviewCardUseCaseProvider).call(review);
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Falha ao gerar card.')),
                          );
                        }
                      },
                      onOpenMovie: (_) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => MovieDetailsPage(movieId: review.tmdbMovieId),
                          ),
                        );
                      },
                      onReact: ref.watch(authSessionProvider).valueOrNull == null
                          ? null
                          : (key) {
                              final user = ref.read(authSessionProvider).valueOrNull!;
                              return ref.read(feedNotifierProvider.notifier).toggleReaction(
                                    reviewId: review.id,
                                    userId: user.id,
                                    reactionKey: key,
                                  );
                            },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Botões do topo do Feed — um pouco menores que o padrão para a barra compacta.
const _headerActionSize = 38.0;

class _FeedTitle extends StatelessWidget {
  const _FeedTitle();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const TuliStatusDot(),
            const SizedBox(width: AppSpacing.sm),
            Text('Feed', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Você e quem você segue',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Sino com contador de notificações não lidas.
class _NotificationsButton extends ConsumerWidget {
  const _NotificationsButton();

  static const _maxShown = 99;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsCountProvider).valueOrNull ?? 0;

    return TuliIconButtonCircle(
      icon: Icons.notifications_none_rounded,
      tooltip: 'Notificações',
      size: _headerActionSize,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NotificationsPage()),
        );
      },
      badge: unread == 0
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: AppShape.borderRadiusPill,
              ),
              child: Text(
                unread > _maxShown ? '$_maxShown+' : '$unread',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.backgroundDeep,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
    );
  }
}
