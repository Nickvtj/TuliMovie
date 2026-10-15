import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/movie_match/domain/entities/match_filters_entity.dart';
import 'package:tulimovie/features/movie_match/domain/entities/match_room_entity.dart';

void main() {
  final room = MatchRoomEntity(
    id: 'room1',
    hostId: 'host',
    participantIds: const ['host', 'ana'],
    invitedIds: const ['ana', 'bia'],
    filters: const MatchFiltersEntity(),
    candidates: const [],
    status: MatchRoomStatus.waiting,
    createdAt: DateTime(2026, 10, 15),
  );

  test('convidado que ainda não entrou pode entrar', () {
    expect(room.canJoin('bia'), isTrue);
  });

  test('quem já entrou ou não foi convidado não entra de novo', () {
    expect(room.canJoin('ana'), isFalse);
    expect(room.canJoin('host'), isFalse);
    expect(room.canJoin('carlos'), isFalse);
  });
}
