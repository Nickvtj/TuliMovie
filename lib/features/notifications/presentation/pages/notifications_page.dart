import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_tile.dart';

/// Central de notificações — ao abrir, marca todas como lidas.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_markAllRead);
  }

  Future<void> _markAllRead() async {
    final userId = ref.read(authSessionProvider).valueOrNull?.id;
    if (userId == null) return;
    try {
      await ref.read(notificationRepositoryProvider).markAllRead(userId);
    } catch (_) {
      // Destaque de "não lida" continua; não bloqueia a leitura da lista.
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TuliScreenHeader(
              mode: TuliScreenHeaderMode.stacked,
              title: 'Notificações',
            ),
            Expanded(
              child: notifications.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: TuliFeedSkeleton(itemCount: 3),
                ),
                error: (e, _) => const TuliEmptyState(
                  message: 'Não foi possível carregar as notificações.',
                  icon: Icons.error_outline_rounded,
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const TuliEmptyState(
                      message: 'Nada por aqui ainda.',
                      icon: Icons.notifications_none_rounded,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) =>
                        NotificationTile(notification: items[index]),
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
