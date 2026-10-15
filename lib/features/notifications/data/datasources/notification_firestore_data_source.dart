import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_firestore_access.dart';
import '../models/notification_model.dart';

/// `users/{uid}/notifications/{id}` — gravado pelo cliente de quem age.
class NotificationFirestoreDataSource {
  NotificationFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  static const usersPath = 'users';
  static const notificationsPath = 'notifications';
  static const recentLimit = 50;

  /// Teto do contador de não lidas (exibido como "99+").
  static const unreadLimit = 100;

  FirebaseFirestore get _db => FirebaseFirestoreAccess.require(override: _firestoreOverride);

  CollectionReference<Map<String, dynamic>> _inbox(String userId) =>
      _db.collection(usersPath).doc(userId).collection(notificationsPath);

  Future<void> createMany(List<NotificationModel> notifications) async {
    if (notifications.isEmpty) return;
    final batch = _db.batch();
    for (final notification in notifications) {
      batch.set(_inbox(notification.recipientId).doc(), notification.toJson());
    }
    await batch.commit();
  }

  Stream<List<NotificationModel>> watchRecent(String userId) {
    return _inbox(userId)
        .orderBy('createdAt', descending: true)
        .limit(recentLimit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromJson(userId, {...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  Stream<int> watchUnreadCount(String userId) {
    return _unread(userId).snapshots().map((snapshot) => snapshot.docs.length);
  }

  Future<void> markAllRead(String userId) async {
    final snapshot = await _unread(userId).get();
    if (snapshot.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Query<Map<String, dynamic>> _unread(String userId) =>
      _inbox(userId).where('read', isEqualTo: false).limit(unreadLimit);
}
