import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/social/domain/entities/follow_status_entity.dart';

void main() {
  test('mútuo quando os dois se seguem', () {
    const status = FollowStatusEntity(isFollowing: true, followsYou: true);
    expect(status.isMutual, isTrue);
  });

  test('não é mútuo quando só a outra pessoa segue', () {
    const status = FollowStatusEntity(followsYou: true);
    expect(status.isMutual, isFalse);
  });

  test('não é mútuo quando só eu sigo', () {
    const status = FollowStatusEntity(isFollowing: true);
    expect(status.isMutual, isFalse);
  });
}
