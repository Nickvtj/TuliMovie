import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../providers/comment_providers.dart';
import '../widgets/comment_input_bar.dart';
import '../widgets/comment_tile.dart';

/// Comentários de um post, em tempo real.
class ReviewCommentsPage extends ConsumerWidget {
  const ReviewCommentsPage({super.key, required this.reviewId});

  final String reviewId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final review = ref.watch(reviewByIdProvider(reviewId)).valueOrNull;
    final comments = ref.watch(commentsProvider(reviewId));
    final me = ref.watch(authSessionProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TuliScreenHeader(
              mode: TuliScreenHeaderMode.stacked,
              title: 'Comentários',
              subtitle: review == null
                  ? null
                  : '${review.participants.firstOrNull?.displayName ?? ''} · ${review.movieTitle}',
            ),
            Expanded(
              child: comments.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: TuliFeedSkeleton(itemCount: 3),
                ),
                error: (e, _) => const TuliEmptyState(
                  message: 'Não foi possível carregar os comentários.',
                  icon: Icons.error_outline_rounded,
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const TuliEmptyState(
                      message: 'Nenhum comentário ainda.\nSeja o primeiro!',
                      icon: Icons.chat_bubble_outline_rounded,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
                    itemBuilder: (context, index) => CommentTile(comment: items[index]),
                  );
                },
              ),
            ),
            if (me != null) CommentInputBar(reviewId: reviewId, author: me),
          ],
        ),
      ),
    );
  }
}
