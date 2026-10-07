import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/pages/group_hub_page.dart';
import '../../../groups/presentation/providers/group_providers.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';
import '../../../share/presentation/providers/share_providers.dart';
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
    final groupsAsync = ref.watch(userGroupsProvider);
    final selectedTab = ref.watch(feedTabGroupIdProvider);
    final groupNames = ref.watch(groupNameMapProvider);

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
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: TuliScreenHeader(
                  mode: TuliScreenHeaderMode.root,
                  leadingStatusDot: true,
                  title: 'Feed das comunidades',
                  trailingActions: [
                    TuliIconButtonCircle(
                      icon: Icons.groups_rounded,
                      tooltip: 'Turma',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const GroupHubPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: groupsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (groups) => _FeedGroupTabs(
                  groups: groups,
                  selectedGroupId: selectedTab,
                  onSelected: (id) {
                    ref.read(feedTabGroupIdProvider.notifier).state = id;
                  },
                ),
              ),
            ),
            if (feed.isInitialLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: TuliFeedSkeleton(itemCount: 4),
                ),
              )
            else if (feed.reviews.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: TuliEmptyState(
                  message: feed.errorMessage ??
                      'Nenhuma avaliação ainda.\nToque no + para buscar um filme e avaliar!',
                  icon: Icons.dynamic_feed_outlined,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList.separated(
                  itemCount: feed.reviews.length + (feed.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
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
                      groupNameMap: groupNames,
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

class _FeedGroupTabs extends StatelessWidget {
  const _FeedGroupTabs({
    required this.groups,
    required this.selectedGroupId,
    required this.onSelected,
  });

  final List<GroupEntity> groups;
  final String? selectedGroupId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.section),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: TuliFilterChip(
                label: 'Todas',
                selected: selectedGroupId == null,
                onSelected: () => onSelected(null),
              ),
            ),
            for (final group in groups)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: TuliFilterChip(
                  label: group.name,
                  selected: selectedGroupId == group.id,
                  onSelected: () => onSelected(group.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
