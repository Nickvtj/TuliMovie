import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/relative_time_pt.dart';
import '../../../comments/presentation/pages/review_comments_page.dart';
import '../../../social/presentation/pages/user_profile_page.dart';
import '../../domain/constants/quick_reactions.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_participant_entity.dart';
import 'quick_reactions_sheet.dart';
import 'spoiler_blur_text.dart';

typedef ReviewCardTap = void Function(ReviewEntity review);

/// Card modular do feed — autor, bloco do filme, comentário e barra de ações.
class ReviewCardWidget extends StatelessWidget {
  const ReviewCardWidget({
    super.key,
    required this.review,
    this.onOpenMovie,
    this.onReact,
    this.onShare,
    this.onCommentsClosed,
    this.onDelete,
    this.compact = false,
  });

  final ReviewEntity review;
  final ReviewCardTap? onOpenMovie;
  final Future<void> Function(String reactionKey)? onReact;
  final VoidCallback? onShare;

  /// Chamado ao voltar dos comentários — permite atualizar contadores.
  final VoidCallback? onCommentsClosed;

  /// Só para o autor: exibe o menu "Excluir avaliação" (com confirmação).
  final Future<void> Function()? onDelete;
  final bool compact;

  Future<void> _openComments(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ReviewCommentsPage(reviewId: review.id)),
    );
    onCommentsClosed?.call();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir avaliação?'),
          content: Text(
            'Sua avaliação de ${review.movieTitle} some do feed e do seu perfil. '
            'Não dá para desfazer.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.neonRedDeep),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await onDelete!();
      messenger.showSnackBar(const SnackBar(content: Text('Avaliação excluída.')));
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final author = review.participants.isNotEmpty ? review.participants.first : null;
    final authorRating = author?.rating ?? review.groupAverageRating;
    final watchedWith = review.participants.skip(1).toList();
    final hasComment = review.comment != null && review.comment!.trim().isNotEmpty;

    return TuliCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
      onTap: onOpenMovie == null ? null : () => onOpenMovie!(review),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (author != null)
            _AuthorHeader(
              author: author,
              authorId: review.authorId,
              timeLabel: formatRelativeTimePt(review.createdAt),
              onDelete: onDelete == null ? null : () => _confirmDelete(context),
            ),
          if (watchedWith.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.people_alt_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'com ${watchedWith.map((p) => p.displayName).join(', ')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _MovieBlock(
            review: review,
            authorRating: authorRating,
            compact: compact,
            textTheme: textTheme,
          ),
          if (hasComment) ...[
            const SizedBox(height: AppSpacing.md),
            if (review.containsSpoiler)
              SpoilerBlurText(text: review.comment!, maxLines: compact ? 3 : 5)
            else
              TuliQuoteBlock(text: review.comment!, maxLines: compact ? 3 : 5),
          ],
          _EngagementSummary(review: review, onOpenComments: () => _openComments(context)),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Row(
            children: [
              _CardActionButton(
                icon: Icons.add_reaction_outlined,
                label: 'Reagir',
                onPressed: onReact == null
                    ? null
                    : () async {
                        final key = await showQuickReactionsSheet(context);
                        if (key != null) await onReact!(key);
                      },
              ),
              _CardActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Comentar',
                onPressed: () => _openComments(context),
              ),
              if (onShare != null)
                _CardActionButton(
                  icon: Icons.ios_share_rounded,
                  label: 'Card',
                  onPressed: onShare,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthorHeader extends StatelessWidget {
  const _AuthorHeader({
    required this.author,
    required this.authorId,
    required this.timeLabel,
    this.onDelete,
  });

  final ReviewParticipantEntity author;

  /// Vazio em posts antigos (sem autor gravado) — sem link para o perfil.
  final String authorId;
  final String timeLabel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: AppShape.borderRadiusMd,
      onTap: authorId.isEmpty
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => UserProfilePage(userId: authorId)),
              );
            },
      child: Row(
        children: [
          TuliRingAvatar(
            displayName: author.displayName,
            imageUrl: author.photoUrl,
            size: 36,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'avaliou · $timeLabel',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            PopupMenuButton<VoidCallback>(
              tooltip: 'Mais opções',
              icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textMuted),
              color: AppColors.surfaceElevated,
              onSelected: (action) => action(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: onDelete,
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.neonRed),
                      SizedBox(width: AppSpacing.md),
                      Text('Excluir avaliação'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MovieBlock extends StatelessWidget {
  const _MovieBlock({
    required this.review,
    required this.authorRating,
    required this.compact,
    required this.textTheme,
  });

  final ReviewEntity review;
  final double authorRating;
  final bool compact;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final year = review.movieReleaseYear?.toString();
    final ratedCount = review.participants.where((p) => p.hasSubmittedRating).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppShape.borderRadiusMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TuliPosterImage(
            posterPath: review.moviePosterPath,
            width: compact ? 60 : 72,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (review.hasDiscordBadge) ...[
                  const DiscordBadge(compact: true),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  review.movieTitle,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (year != null) ...[
                  const SizedBox(height: 2),
                  TuliMetaRow(year: year),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    TuliRatingStars(
                      value: authorRating,
                      readOnly: true,
                      starSize: compact ? 15 : 17,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      authorRating.toStringAsFixed(1),
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (ratedCount > 1) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Média de quem assistiu: ${review.groupAverageRating.toStringAsFixed(1)} ★',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "😂😭 3 reações · 2 comentários" — oculto quando não há interação.
class _EngagementSummary extends StatelessWidget {
  const _EngagementSummary({required this.review, required this.onOpenComments});

  final ReviewEntity review;
  final VoidCallback onOpenComments;

  @override
  Widget build(BuildContext context) {
    final used = QuickReactions.options.where((option) => review.reactionCount(option.key) > 0);
    final reactionTotal = used.fold<int>(0, (sum, option) => sum + review.reactionCount(option.key));
    final comments = review.commentCount;
    if (reactionTotal == 0 && comments == 0) return const SizedBox.shrink();

    final style = Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        children: [
          if (reactionTotal > 0) ...[
            Text(used.map((option) => option.emoji).join(), style: style),
            const SizedBox(width: 6),
            Text(reactionTotal == 1 ? '1 reação' : '$reactionTotal reações', style: style),
          ],
          const Spacer(),
          if (comments > 0)
            InkWell(
              onTap: onOpenComments,
              borderRadius: AppShape.borderRadiusSm,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  comments == 1 ? '1 comentário' : '$comments comentários',
                  style: style,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Botão da barra inferior do card — divide a largura igualmente.
class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null ? AppColors.textMuted : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppShape.borderRadiusSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
