import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../social/presentation/providers/social_providers.dart';
import '../../domain/entities/match_filters_entity.dart';
import '../../domain/usecases/pick_match_candidates_use_case.dart';
import '../providers/match_providers.dart';
import '../widgets/match_setup_sheet.dart';
import 'match_room_page.dart';

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

  Future<void> _createRoom() async {
    final user = ref.read(authSessionProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isCreating = true);
    try {
      // Exclui o que o host e os convidados já viram.
      final candidates = await ref.read(pickMatchCandidatesUseCaseProvider).call(
            hostId: user.id,
            participantIds: {user.id, ..._invitedIds},
            filters: _filters,
          );

      if (candidates.isEmpty) {
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
            candidates: candidates,
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          children: [
            const TuliScreenHeader(
              mode: TuliScreenHeaderMode.stacked,
              title: 'Sala de Match',
            ),
            Text(
              'Escolha quem chamar. Cada pessoa recebe um convite nas notificações '
              'e entra na sala com um toque.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Filtros da rodada', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () async {
                final updated = await MatchSetupSheet.show(context, initial: _filters);
                if (updated != null) setState(() => _filters = updated);
              },
              icon: const Icon(Icons.tune),
              label: const Text('Personalizar filtros'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Convidar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (user != null)
              _InviteList(
                userId: user.id,
                invitedIds: _invitedIds,
                onToggle: _toggleInvite,
              ),
            const SizedBox(height: AppSpacing.lg),
            TuliButton(
              label: _invitedIds.isEmpty
                  ? 'Jogar sozinho (${PickMatchCandidatesUseCase.candidateCount} filmes)'
                  : 'Criar sala e convidar ${_invitedIds.length}',
              expand: true,
              isLoading: _isCreating,
              onPressed: user == null || _isCreating ? null : _createRoom,
            ),
          ],
        ),
      ),
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
              return Text(
                'Você ainda não segue ninguém. Siga pessoas pela lupa do Feed para convidar.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TuliCard(
        variant: selected ? TuliCardVariant.goldAccent : TuliCardVariant.standard,
        onTap: onToggle,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: CheckboxListTile(
          value: selected,
          onChanged: (_) => onToggle(),
          title: Text(friend.displayName),
          subtitle: friend.hasUsername ? Text('@${friend.username}') : null,
          secondary: TuliRingAvatar(displayName: friend.displayName, imageUrl: friend.photoUrl),
          controlAffinity: ListTileControlAffinity.trailing,
          activeColor: AppColors.gold,
        ),
      ),
    );
  }
}
