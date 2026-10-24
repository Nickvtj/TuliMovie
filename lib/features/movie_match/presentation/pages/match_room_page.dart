import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/match_room_entity.dart';
import '../providers/match_providers.dart';
import 'swipe_match_page.dart';

/// Sala de espera do Match. Convidado que abre a sala entra automaticamente.
class MatchRoomPage extends ConsumerStatefulWidget {
  const MatchRoomPage({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<MatchRoomPage> createState() => _MatchRoomPageState();
}

class _MatchRoomPageState extends ConsumerState<MatchRoomPage> {
  bool _joinRequested = false;

  void _joinIfInvited(MatchRoomEntity room, String userId) {
    if (_joinRequested || !room.canJoin(userId)) return;
    _joinRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(matchRoomRepositoryProvider).joinRoom(roomId: room.id, userId: userId);
      } on AppException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    });
  }

  void _openSwipes() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => SwipeMatchPage(roomId: widget.roomId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(matchRoomStreamProvider(widget.roomId));
    final user = ref.watch(authSessionProvider).valueOrNull;

    return roomAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const Scaffold(
        body: TuliEmptyState(
          message: 'Você não tem acesso a esta sala.',
          icon: Icons.lock_outline_rounded,
        ),
      ),
      data: (room) {
        if (room == null) {
          return const Scaffold(body: Center(child: Text('Sala encerrada.')));
        }
        if (user != null) _joinIfInvited(room, user.id);
        // Já dentro da sala: os votos carregam aqui, e o swipe abre pronto.
        if (user != null && room.participantIds.contains(user.id)) {
          ref.watch(matchLikesStreamProvider(widget.roomId));
        }

        final isHost = user?.id == room.hostId;
        final everyone = {room.hostId, ...room.invitedIds, ...room.participantIds}.toList();

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              children: [
                const TuliScreenHeader(
                  mode: TuliScreenHeaderMode.stacked,
                  title: 'Sala de Match',
                ),
                TuliCard(
                  variant: TuliCardVariant.goldAccent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(room.status),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text('Na sala: ${room.participantIds.length} de ${everyone.length}'),
                      Text('Filmes na rodada: ${room.candidates.length}'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Quem está na rodada', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final userId in everyone)
                  _RoomMemberRow(
                    userId: userId,
                    isHost: userId == room.hostId,
                    joined: room.participantIds.contains(userId),
                  ),
                const SizedBox(height: AppSpacing.lg),
                if (room.status == MatchRoomStatus.matched)
                  TuliButton(label: 'Ver filme match', expand: true, onPressed: _openSwipes)
                else if (isHost)
                  TuliButton(
                    label: 'Iniciar swipes',
                    expand: true,
                    onPressed: () async {
                      await ref.read(matchRoomRepositoryProvider).startSwiping(widget.roomId);
                      if (mounted) _openSwipes();
                    },
                  )
                else
                  TuliButton(
                    label: room.status == MatchRoomStatus.swiping
                        ? 'Entrar nos swipes'
                        : 'Aguardando o host iniciar...',
                    expand: true,
                    onPressed: room.status == MatchRoomStatus.swiping ? _openSwipes : null,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _statusLabel(MatchRoomStatus status) {
    return switch (status) {
      MatchRoomStatus.waiting => 'Aguardando a galera',
      MatchRoomStatus.swiping => 'Swipes rolando',
      MatchRoomStatus.matched => 'Deu match!',
      MatchRoomStatus.closed => 'Sala encerrada',
    };
  }
}

class _RoomMemberRow extends ConsumerWidget {
  const _RoomMemberRow({required this.userId, required this.isHost, required this.joined});

  final String userId;
  final bool isHost;
  final bool joined;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider(userId)).valueOrNull;
    final name = profile?.displayName ?? '...';
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          TuliRingAvatar(displayName: name, imageUrl: profile?.photoUrl, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(isHost ? '$name (host)' : name, style: textTheme.bodyMedium),
          ),
          Text(
            joined ? 'Na sala' : 'Convidado',
            style: textTheme.labelSmall?.copyWith(
              color: joined ? AppColors.gold : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
