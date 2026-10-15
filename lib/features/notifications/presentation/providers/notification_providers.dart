import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) => sl<NotificationRepository>());

final notificationsProvider = StreamProvider.autoDispose<List<NotificationEntity>>((ref) {
  final userId = ref.watch(authSessionProvider.select((s) => s.valueOrNull?.id));
  if (userId == null) return const Stream.empty();
  return ref.watch(notificationRepositoryProvider).watchNotifications(userId);
});

/// Não lidas do usuário logado — badge do sino.
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(authSessionProvider.select((s) => s.valueOrNull?.id));
  if (userId == null) return Stream.value(0);
  return ref.watch(notificationRepositoryProvider).watchUnreadCount(userId);
});
