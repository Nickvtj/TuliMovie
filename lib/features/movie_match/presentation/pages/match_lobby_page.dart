import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../social/presentation/providers/social_providers.dart';
import '../../domain/entities/match_filters_entity.dart';
import '../providers/match_providers.dart';
import '../widgets/match_active_filters_bar.dart';
import '../widgets/match_setup_sheet.dart';
import 'match_room_page.dart';

/// Aba "Match": monta a rodada (filtros + convidados) e cria a sala.
class MatchLobbyPage extends ConsumerStatefulWidget {
  const MatchLobbyPage({super.key});

  @override
  ConsumerState<MatchLobbyPage> createState() => _MatchLobbyPageState();
}

class _MatchLobbyPageState extends ConsumerState<MatchLobbyPage> {
  MatchFiltersEntity _filters = const MatchFiltersEntity();
  final _invitedIds = <String>{};
  bool _isCreating = false;

  void _toggleInvite(String userId) {
    setState(() {
      if (!_invitedIds.remove(userId)) _invitedIds.add(userId);
    });
  }

  Future<void> _editFilters() async {
    final updated = await MatchSetupSheet.show(context, initial: _filters);
    if (updated != null) setState(() => _filters = updated);
  }

  Future<void> _createRoom() async {
    final user = ref.read(authSessionProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isCreating = true);
    try {
      // Exclui o que o host e os convidados já viram.
      final batch = await ref.read(pickMatchCandidatesUseCaseProvider).call(
            hostId: user.id,
            participantIds: {user.id, ..._invitedIds},
            filters: _filters,
          );

      if (batch.candidates.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum filme novo encontrado com esses filtros.')),
          );
        }
        return;
      }

      final room = await ref.read(matchRoomRepositoryProvider).createRoom(
            host: user,
            invitedIds: _invitedIds.toList(),
            filters: _filters,
            candidates: batch.candidates,
            nextCandidatePage: batch.nextPage,
          );

      if (!mounted) return;
      setState(_invitedIds.clear);
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => MatchRoomPage(roomId: room.id)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar sala: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authSessionProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                children: [
                  const TuliScreenHeader(
                    title: 'Match',
                    subtitle: 'Decida o filme com seus amigos, no swipe',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _HowItWorks(),
                        const SizedBox(height: AppSpacing.xl),
                        TuliSectionTitle(
                          title: 'Filtros da rodada',
                          actionLabel: 'Personalizar',
                          actionIcon: Icons.tune_rounded,
                          onAction: _editFilters,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _FiltersSummary(filters: _filters, onTap: _editFilters),
                        const SizedBox(height: AppSpacing.xl),
                        TuliSectionTitle(
                          title: 'Convidar amigos',
                          trailing:
                              _invitedIds.isEmpty ? null : '${_invitedIds.length} selecionado(s)',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (user != null)
                          _InviteList(
                            userId: user.id,
                            invitedIds: _invitedIds,
                            onToggle: _toggleInvite,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.backgroundDeep,
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: TuliButton(
                label: _invitedIds.isEmpty
                    ? 'Jogar sozinho'
                    : 'Criar sala e convidar ${_invitedIds.length}',
                icon: Icons.play_arrow_rounded,
                expand: true,
                isLoading: _isCreating,
                onPressed: user == null || _isCreating ? null : _createRoom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Passo a passo curto da dinâmica.
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static const _steps = [
    (Icons.tune_rounded, 'Escolha os filtros'),
    (Icons.group_add_rounded, 'Convide amigos'),
    (Icons.swipe_rounded, 'Deem swipe juntos'),
    (Icons.favorite_rounded, 'Todos curtiram? Match!'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TuliCard(
      variant: TuliCardVariant.goldAccent,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          for (final (index, step) in _steps.indexed) ...[
            if (index > 0) const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(step.$1, size: 18, color: AppColors.gold),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(step.$2, style: textTheme.bodyMedium)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FiltersSummary extends StatelessWidget {
  const _FiltersSummary({required this.filters, required this.onTap});

  final MatchFiltersEntity filters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TuliCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: filters == const MatchFiltersEntity()
          ? Row(
              children: [
                const Icon(Icons.all_inclusive_rounded, color: AppColors.textMuted, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Sem filtros — qualquer gênero, época e streaming.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            )
          : MatchActiveFiltersBar(filters: filters),
    );
  }
}

/// Pessoas que o usuário segue, marcáveis como convidadas.
class _InviteList extends ConsumerWidget {
  const _InviteList({
    required this.userId,
    required this.invitedIds,
    required this.onToggle,
  });

  final String userId;
  final Set<String> invitedIds;
  final void Function(String userId) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(followingProvider(userId)).when(
          loading: () => const TuliFeedSkeleton(itemCount: 2),
          error: (e, _) => const Text('Não foi possível carregar quem você segue.'),
          data: (following) {
            if (following.isEmpty) {
              return const TuliCard(
                child: Text(
                  'Você ainda não segue ninguém. Siga pessoas pela lupa do Feed para convidar.',
                ),
              );
            }
            return Column(
              children: [
                for (final friend in following)
                  _InviteTile(
                    friend: friend,
                    selected: invitedIds.contains(friend.id),
                    onToggle: () => onToggle(friend.id),
                  ),
              ],
            );
          },
        );
  }
}

class _InviteTile extends StatelessWidget {
  const _InviteTile({required this.friend, required this.selected, required this.onToggle});

  final UserEntity friend;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TuliCard(
        variant: selected ? TuliCardVariant.goldAccent : TuliCardVariant.standard,
        onTap: onToggle,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        child: Row(
          children: [
            TuliRingAvatar(displayName: friend.displayName, imageUrl: friend.photoUrl, size: 38),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(friend.displayName, style: textTheme.titleSmall),
                  if (friend.hasUsername)
                    Text(
                      '@${friend.username}',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: AppDurations.fast,
              child: Icon(
                selected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                key: ValueKey(selected),
                color: selected ? AppColors.gold : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
