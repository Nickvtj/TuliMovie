import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../reviews/presentation/providers/create_review_providers.dart';
import '../../domain/entities/match_filters_entity.dart';
import '../../domain/entities/match_room_entity.dart';
import '../providers/match_providers.dart';
import 'swipe_match_page.dart';

class MatchLobbyPage extends ConsumerStatefulWidget {
  const MatchLobbyPage({super.key});

  @override
  ConsumerState<MatchLobbyPage> createState() => _MatchLobbyPageState();
}

class _MatchLobbyPageState extends ConsumerState<MatchLobbyPage> {
  final _joinController = TextEditingController();
  int? _providerId;
  int? _maxRuntime;
  final _selectedFriendIds = <String>{};
  String? _activeRoomId;
  bool _isCreating = false;

  @override
  void dispose() {
    _joinController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final user = ref.read(authSessionProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isCreating = true);
    try {
      final members =
          await ref.read(listGroupMembersUseCaseProvider).call(excludeUserId: user.id);
      final participantIds = members
          .where((m) => _selectedFriendIds.contains(m.id))
          .map((m) => m.id)
          .toList();

      final filters = MatchFiltersEntity(
        withWatchProviderId: _providerId,
        maxRuntimeMinutes: _maxRuntime,
      );

      final candidates = await ref.read(pickMatchCandidatesUseCaseProvider).call(
            participantIds: {user.id, ...participantIds},
            filters: filters,
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
            filters: filters,
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
    final membersAsync = ref.watch(
      FutureProvider((ref) async {
        if (user == null) return const [];
        return ref.read(listGroupMembersUseCaseProvider).call(excludeUserId: user.id);
      }),
    );

    if (_activeRoomId != null) {
      return _ActiveRoomView(roomId: _activeRoomId!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sala de Match')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Filtros da rodada', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<int?>(
            value: _providerId,
            decoration: const InputDecoration(labelText: 'Streaming'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Qualquer')),
              DropdownMenuItem(value: 8, child: Text('Netflix')),
              DropdownMenuItem(value: 9, child: Text('Prime Video')),
              DropdownMenuItem(value: 337, child: Text('Disney+')),
              DropdownMenuItem(value: 384, child: Text('Max')),
            ],
            onChanged: (value) => setState(() => _providerId = value),
          ),
          const SizedBox(height: 12),
          Text('Duração máxima: ${_maxRuntime ?? 180} min'),
          Slider(
            min: 60,
            max: 180,
            divisions: 4,
            value: (_maxRuntime ?? 180).toDouble(),
            activeColor: AppColors.gold,
            label: '${_maxRuntime ?? 180} min',
            onChanged: (v) => setState(() => _maxRuntime = v.round()),
          ),
          const SizedBox(height: 16),
          Text('Quem está no sofá?', style: Theme.of(context).textTheme.titleMedium),
          membersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: TuliFeedSkeleton(itemCount: 2),
            ),
            error: (_, __) => const Text('Erro ao carregar amigos.'),
            data: (members) {
              if (members.isEmpty) {
                return const Text('Sem amigos cadastrados — você pode criar a sala solo.');
              }
              return Column(
                children: members.map((member) {
                  final selected = _selectedFriendIds.contains(member.id);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (_) {
                      setState(() {
                        if (selected) {
                          _selectedFriendIds.remove(member.id);
                        } else {
                          _selectedFriendIds.add(member.id);
                        }
                      });
                    },
                    title: Text(member.displayName),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          TuliButton(
            label: 'Criar sala (10 filmes)',
            expand: true,
            isLoading: _isCreating,
            onPressed: user == null || _isCreating ? null : _createRoom,
          ),
          const SizedBox(height: 24),
          TuliInputField(
            label: 'Entrar com código',
            hint: 'Ex: A1B2C3',
            controller: _joinController,
          ),
          const SizedBox(height: 12),
          TuliButton(
            label: 'Entrar na sala',
            variant: TuliButtonVariant.secondary,
            expand: true,
            onPressed: user == null ? null : _joinRoom,
          ),
        ],
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
          appBar: AppBar(title: Text('Sala ${room.shortCode}')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                const SizedBox(height: 16),
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
        );
      },
    );
  }
}
