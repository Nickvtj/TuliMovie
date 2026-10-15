import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/auth/domain/entities/user_entity.dart';
import 'package:tulimovie/features/notifications/data/models/notification_model.dart';
import 'package:tulimovie/features/notifications/domain/entities/notification_entity.dart';

void main() {
  test('convite de Match leva o ator, a sala e nasce não lido', () {
    final model = NotificationModel.fromActor(
      recipientId: 'bia',
      type: NotificationType.matchInvite,
      actor: const UserEntity(id: 'ana', email: '', displayName: 'Ana'),
      roomId: 'room1',
    );
    final json = model.toJson();

    expect(json['type'], 'matchInvite');
    expect(json['actorId'], 'ana');
    expect(json['actorName'], 'Ana');
    expect(json['roomId'], 'room1');
    expect(json['read'], isFalse);
    expect(json.containsKey('recipientId'), isFalse);
  });
}
