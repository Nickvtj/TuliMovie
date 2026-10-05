import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/match_room_entity.dart';
import '../models/match_room_model.dart';

class MatchRoomFirestoreDataSource {
  MatchRoomFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const collectionPath = 'matches';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection(collectionPath);

  Stream<MatchRoomModel?> watchRoom(String roomId) {
    return _rooms.doc(roomId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return MatchRoomModel.fromJson({...snap.data()!, 'id': snap.id});
    });
  }

  Stream<Map<String, Map<int, bool>>> watchLikes(String roomId) {
    return _rooms.doc(roomId).collection('swipes').snapshots().map((snapshot) {
      final likes = <String, Map<int, bool>>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String? ?? doc.id;
        final votes = data['votes'] as Map<String, dynamic>? ?? {};
        likes[userId] = votes.map(
          (key, value) => MapEntry(int.parse(key), value == true),
        );
      }
      return likes;
    });
  }

  Future<MatchRoomModel> createRoom(MatchRoomModel room) async {
    final doc = _rooms.doc();
    final payload = MatchRoomModel(
      id: doc.id,
      hostId: room.hostId,
      participantIds: room.participantIds,
      filters: room.filters,
      candidates: room.candidates,
      status: room.status,
      matchedMovieId: room.matchedMovieId,
      createdAt: room.createdAt,
      expiresAt: room.expiresAt,
    );
    await doc.set(payload.toJson());
    return payload;
  }

  Future<void> joinRoom({required String roomId, required String userId}) async {
    await _rooms.doc(roomId).update({
      'participantIds': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> startSwiping(String roomId) async {
    await _rooms.doc(roomId).update({'status': MatchRoomStatus.swiping.name});
  }

  Future<void> submitSwipe({
    required String roomId,
    required String userId,
    required int tmdbMovieId,
    required bool liked,
  }) async {
    final ref = _rooms.doc(roomId).collection('swipes').doc(userId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = Map<String, dynamic>.from(
        (snap.data()?['votes'] as Map<String, dynamic>?) ?? {},
      );
      current[tmdbMovieId.toString()] = liked;
      tx.set(ref, {'userId': userId, 'votes': current}, SetOptions(merge: true));
    });
  }

  Future<void> markMatched({
    required String roomId,
    required int tmdbMovieId,
  }) async {
    await _rooms.doc(roomId).update({
      'status': MatchRoomStatus.matched.name,
      'matchedMovieId': tmdbMovieId,
    });
  }

  Future<MatchRoomModel?> findRoomByShortCode(String shortCode) async {
    final normalized = shortCode.trim().toUpperCase();
    if (normalized.length < 4) return null;

    final snapshot = await _rooms
        .orderBy('createdAt', descending: true)
        .limit(40)
        .get();

    for (final doc in snapshot.docs) {
      if (doc.id.toUpperCase().startsWith(normalized)) {
        return MatchRoomModel.fromJson({...doc.data(), 'id': doc.id});
      }
    }
    return null;
  }
}
