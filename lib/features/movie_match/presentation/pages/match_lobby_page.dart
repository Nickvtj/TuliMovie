import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../groups/presentation/providers/group_providers.dart';
import '../../domain/entities/match_filters_entity.dart';
import '../../domain/entities/match_room_entity.dart';
import '../providers/match_providers.dart';
import '../widgets/match_setup_sheet.dart';
import 'swipe_match_page.dart';

class MatchLobbyPage extends ConsumerStatefulWidget {
  const MatchLobbyPage({super.key});

  @override
  ConsumerState<MatchLobbyPage> createState() => _MatchLobbyPageState();
}

class _MatchLobbyPageState extends ConsumerState<MatchLobbyPage> {
  final _joinController = TextEditingController();
  MatchFiltersEntity _filters = const MatchFiltersEntity();
  String? _activeRoomId;
  bool _isCreating = false;

  @override
  void dispose() {
    _joinController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final user = ref.read(authSessionProvider).valueOrNull;
    final groupId = ref.read(activeGroupIdProvider);
    if (user == null || groupId == null) return;

    setState(() => _isCreating = true);
    try {
      const participantIds = <String>[];

      final candidates = await ref.read(pickMatchCandidatesUseCaseProvider).call(
            groupId: groupId,
            participantIds: {user.id},
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
            hostId: user.id,
            participantIds: participantIds,
            filters: _filters,
            candidates: candidates,
          );

      setState(() => _activeRoomId = room.id);
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

  Future<void> _joinRoom() async {
    final user = ref.read(authSessionProvider).valueOrNull;
    if (user == null) return;

    final code = _joinController.text.trim();
    final room = await ref.read(matchRoomRepositoryProvider).findRoomByShortCode(code);
    if (room == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sala não encontrada.')),
        );
      }
      return;
    }

    await ref.read(matchRoomRepositoryProvider).joinRoom(roomId: room.id, userId: user.id);
    if (!mounted) return;
    setState(() => _activeRoomId = room.id);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authSessionProvider).valueOrNull;

    if (_activeRoomId != null) {
      return _ActiveRoomView(roomId: _activeRoomId!);
    }

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
            'Crie a sala e compartilhe o código. Você pode jogar sozinho até alguém entrar.',
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
          TuliButton(
            label: 'Criar sala (10 filmes)',
            expand: true,
            isLoading: _isCreating,
            onPressed: user == null || _isCreating ? null : _createRoom,
          ),
          const SizedBox(height: AppSpacing.xxl),
          TuliInputField(
            label: 'Entrar com código',
            hint: 'Ex: A1B2C3',
            controller: _joinController,
          ),
          const SizedBox(height: AppSpacing.md),
          TuliButton(
            label: 'Entrar na sala',
            variant: TuliButtonVariant.secondary,
            expand: true,
            onPressed: user == null ? null : _joinRoom,
          ),
          ],
        ),
      ),
    );
  }
}

class _ActiveRoomView extends ConsumerWidget {
  const _ActiveRoomView({required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(matchRoomStreamProvider(roomId));
    final user = ref.watch(authSessionProvider).valueOrNull;

    return roomAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (room) {
        if (room == null) {
          return const Scaffold(body: Center(child: Text('Sala encerrada.')));
        }

        final isHost = user?.id == room.hostId;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TuliScreenHeader(
                    mode: TuliScreenHeaderMode.stacked,
                    title: 'Sala ${room.shortCode}',
                  ),
                  TuliCard(
                  variant: TuliCardVariant.goldAccent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Código: ${room.shortCode}',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text('Participantes: ${room.participantIds.length}'),
                      Text('Filmes na rodada: ${room.candidates.length}'),
                      Text('Status: ${room.status.name}'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (room.status == MatchRoomStatus.matched)
                  TuliButton(
                    label: 'Ver filme match',
                    expand: true,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => SwipeMatchPage(roomId: roomId),
                        ),
                      );
                    },
                  )
                else if (isHost)
                  TuliButton(
                    label: 'Iniciar swipes',
                    expand: true,
                    onPressed: () async {
                      await ref.read(matchRoomRepositoryProvider).startSwiping(roomId);
                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => SwipeMatchPage(roomId: roomId),
                        ),
                      );
                    },
                  )
                else
                  TuliButton(
                    label: 'Aguardando host iniciar...',
                    expand: true,
                    onPressed: room.status == MatchRoomStatus.swiping
                        ? () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => SwipeMatchPage(roomId: roomId),
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
