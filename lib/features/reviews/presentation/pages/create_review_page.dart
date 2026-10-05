import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../../../movies/domain/entities/movie_details_entity.dart';
import '../../../movies/presentation/providers/movie_providers.dart';
import '../../domain/entities/create_review_draft.dart';
import '../../domain/entities/rating_dimension.dart';
import '../notifiers/create_review_notifier.dart';
import '../providers/create_review_providers.dart';

class CreateReviewPage extends ConsumerWidget {
  const CreateReviewPage({super.key, required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(movieDetailsProvider(movieId));
    final user = ref.watch(authSessionProvider);

    return movieAsync.when(
      loading: () => const Scaffold(
        body: Center(child: TuliPosterSkeleton(width: 120)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Erro: $e')),
      ),
      data: (movie) {
        final author = user.valueOrNull;
        if (author == null) {
          return const Scaffold(body: Center(child: Text('Faça login para avaliar.')));
        }

        return _CreateReviewFlow(
          movie: movie,
          author: author,
          movieId: movieId,
        );
      },
    );
  }
}

class _CreateReviewFlow extends ConsumerWidget {
  const _CreateReviewFlow({
    required this.movie,
    required this.author,
    required this.movieId,
  });

  final MovieDetailsEntity movie;
  final UserEntity author;
  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (movieId: movieId, userId: author.id);
    final state = ref.watch(createReviewNotifierProvider(key));
    final notifier = ref.read(createReviewNotifierProvider(key).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Avaliar · ${movie.movie.title}'),
      ),
      body: Column(
        children: [
          _StepHeader(currentStep: state.step),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppDurations.normal,
              child: switch (state.step) {
                0 => _FriendsStep(
                    key: const ValueKey('friends'),
                    state: state,
                    onToggle: notifier.toggleFriend,
                  ),
                1 => _RatingsStep(
                    key: const ValueKey('ratings'),
                    draft: state.draft,
                    onChanged: notifier.setDimensionRating,
                  ),
                _ => _CommentStep(
                    key: const ValueKey('comment'),
                    comment: state.draft.comment,
                    containsSpoiler: state.draft.containsSpoiler,
                    onCommentChanged: notifier.setComment,
                    onSpoilerChanged: notifier.setContainsSpoiler,
                  ),
              },
            ),
          ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                state.errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neonRed),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (state.step > 0)
                  Expanded(
                    child: TuliButton(
                      label: 'Voltar',
                      variant: TuliButtonVariant.secondary,
                      onPressed: state.isSubmitting ? null : notifier.previousStep,
                    ),
                  ),
                if (state.step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TuliButton(
                    label: state.step < CreateReviewState.maxStep ? 'Continuar' : 'Publicar',
                    expand: true,
                    isLoading: state.isSubmitting,
                    onPressed: state.isSubmitting
                        ? null
                        : () async {
                            if (state.step < CreateReviewState.maxStep) {
                              notifier.nextStep();
                              return;
                            }
                            final ok = await notifier.submit();
                            if (!context.mounted || !ok) return;
                            ref.invalidate(feedNotifierProvider);
                            ref.invalidate(movieGroupReviewsProvider(movieId));
                            Navigator.of(context).pop(true);
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.currentStep});

  final int currentStep;

  static const _labels = ['Galera', '5 Perguntas', 'Comentário'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final active = index == currentStep;
          final done = index < currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == _labels.length - 1 ? 0 : 8),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : AppColors.surfaceElevated,
                  borderRadius: AppShape.borderRadiusSm,
                  border: Border.all(
                    color: active || done
                        ? AppColors.gold.withValues(alpha: 0.45)
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Text(
                  _labels[index],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: active ? AppColors.gold : AppColors.textSecondary,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FriendsStep extends StatelessWidget {
  const _FriendsStep({
    super.key,
    required this.state,
    required this.onToggle,
  });

  final CreateReviewState state;
  final void Function(UserEntity friend) onToggle;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMembers) {
      return const Center(child: TuliFeedSkeleton(itemCount: 3));
    }

    if (state.members.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Ninguém mais cadastrado ainda.\nVocê pode publicar só a sua nota.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Quem assistiu com você?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...state.members.map((friend) {
          final selected = state.draft.selectedFriends.any((u) => u.id == friend.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TuliCard(
              variant: selected ? TuliCardVariant.goldAccent : TuliCardVariant.standard,
              onTap: () => onToggle(friend),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: CheckboxListTile(
                value: selected,
                onChanged: (_) => onToggle(friend),
                title: Text(friend.displayName),
                subtitle: Text(friend.email, style: Theme.of(context).textTheme.bodySmall),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.gold,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _RatingsStep extends StatelessWidget {
  const _RatingsStep({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final CreateReviewDraft draft;
  final void Function(RatingDimension dimension, double value) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: RatingDimension.all.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final dimension = RatingDimension.all[index];
        final value = draft.answers[dimension] ?? 0;

        return TuliCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dimension.title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(dimension.subtitle, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              TuliRatingStars(
                value: value,
                allowHalfStars: true,
                onChanged: (rating) => onChanged(dimension, rating),
              ),
              Slider(
                value: (value <= 0 ? 3 : value).clamp(1, 5),
                min: 1,
                max: 5,
                divisions: 8,
                activeColor: AppColors.gold,
                onChanged: (v) => onChanged(dimension, v),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentStep extends StatelessWidget {
  const _CommentStep({
    super.key,
    required this.comment,
    required this.containsSpoiler,
    required this.onCommentChanged,
    required this.onSpoilerChanged,
  });

  final String comment;
  final bool containsSpoiler;
  final ValueChanged<String> onCommentChanged;
  final ValueChanged<bool> onSpoilerChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TuliInputField(
          label: 'Comentário da sessão',
          hint: 'O que a galera achou?',
          maxLines: 5,
          onChanged: onCommentChanged,
        ),
        const SizedBox(height: 12),
        TuliCard(
          variant: containsSpoiler ? TuliCardVariant.alert : TuliCardVariant.standard,
          child: SwitchListTile(
            value: containsSpoiler,
            onChanged: onSpoilerChanged,
            title: const Text('Contém spoiler'),
            subtitle: const Text('O feed aplicará blur automático no texto.'),
            activeThumbColor: AppColors.neonRed,
          ),
        ),
        if (comment.isNotEmpty && containsSpoiler) ...[
          const SizedBox(height: 16),
          Text('Prévia no feed', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TuliCard(
            child: Text(
              comment,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}
