import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';
import '../providers/feed_providers.dart';
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
    final user = ref.watch(authSessionProvider).valueOrNull;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () => ref.read(feedNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text('Feed da turma', style: Theme.of(context).textTheme.headlineSmall),
              actions: [
                IconButton(
                  tooltip: 'Sair',
                  onPressed: () => ref.read(signOutUseCaseProvider)(),
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
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
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      feed.errorMessage ??
                          'Nenhuma avaliação ainda.\nBusque um filme e registre a sessão!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                      onOpenMovie: (_) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => MovieDetailsPage(movieId: review.tmdbMovieId),
                          ),
                        );
                      },
                      onReact: user == null
                          ? null
                          : (key) => ref.read(feedNotifierProvider.notifier).toggleReaction(
                                reviewId: review.id,
                                userId: user.id,
                                reactionKey: key,
                              ),
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
