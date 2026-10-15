import '../entities/notification_entity.dart';

abstract interface class NotificationRepository {
  Stream<List<NotificationEntity>> watchNotifications(String userId);

  Stream<int> watchUnreadCount(String userId);

  Future<void> markAllRead(String userId);
}
