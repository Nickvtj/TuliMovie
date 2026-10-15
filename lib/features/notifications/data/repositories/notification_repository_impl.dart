import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_firestore_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._dataSource);

  final NotificationFirestoreDataSource _dataSource;

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    return _dataSource
        .watchRecent(userId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Stream<int> watchUnreadCount(String userId) => _dataSource.watchUnreadCount(userId);

  @override
  Future<void> markAllRead(String userId) async {
    try {
      await _dataSource.markAllRead(userId);
    } on FirebaseException catch (e) {
      throw AppException(
        message: 'Não foi possível atualizar as notificações.',
        type: AppExceptionType.server,
        cause: e,
      );
    }
  }
}
