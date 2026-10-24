import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_firestore_access.dart';
import '../../domain/entities/match_candidate_entity.dart';
import '../../domain/entities/match_room_entity.dart';
import '../models/match_room_model.dart';

class MatchRoomFirestoreDataSource {
  MatchRoomFirestoreDataSource({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  static const collectionPath = 'matches';

  final FirebaseFirestore? _firestoreOverride;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      FirebaseFirestoreAccess.require(override: _firestoreOverride).collection(collectionPath);

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
      invitedIds: room.invitedIds,
      filters: room.filters,
      candidates: room.candidates,
      status: room.status,
      matchedMovieId: room.matchedMovieId,
      nextCandidatePage: room.nextCandidatePage,
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

  /// Acrescenta o próximo lote de filmes. Só grava se ninguém buscou
  /// [fromPage] antes (dois participantes podem pedir mais ao mesmo tempo).
  Future<void> appendCandidates({
    required String roomId,
    required int fromPage,
    required List<MatchCandidateEntity> candidates,
    required int? nextPage,
  }) async {
    final ref = _rooms.doc(roomId);
    await FirebaseFirestoreAccess.require(override: _firestoreOverride).runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null || (data['nextCandidatePage'] as num?)?.toInt() != fromPage) return;

      final existingIds = (data['candidates'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => (item['tmdbMovieId'] as num).toInt())
          .toSet();
      final fresh = candidates.where((c) => !existingIds.contains(c.tmdbMovieId));

      tx.update(ref, {
        'candidates': FieldValue.arrayUnion(fresh.map(MatchRoomModel.candidateToJson).toList()),
        'nextCandidatePage': nextPage ?? FieldValue.delete(),
      });
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
    await FirebaseFirestoreAccess.require(override: _firestoreOverride).runTransaction((tx) async {
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
}
