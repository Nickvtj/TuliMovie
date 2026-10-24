import 'dart:async';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../notifications/data/datasources/notification_firestore_data_source.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../domain/entities/match_candidate_entity.dart';
import '../../domain/entities/match_filters_entity.dart';
import '../../domain/entities/match_room_entity.dart';
import '../../domain/repositories/match_room_repository.dart';
import '../datasources/match_room_firestore_data_source.dart';
import '../models/match_room_model.dart';

class MatchRoomRepositoryImpl implements MatchRoomRepository {
  MatchRoomRepositoryImpl(this._dataSource, this._notifications);

  final MatchRoomFirestoreDataSource _dataSource;
  final NotificationFirestoreDataSource _notifications;

  @override
  Stream<MatchRoomEntity?> watchRoom(String roomId) {
    return _dataSource.watchRoom(roomId).map((model) => model?.toEntity());
  }

  @override
  Stream<Map<String, Map<int, bool>>> watchLikes(String roomId) {
    return _dataSource.watchLikes(roomId);
  }

  @override
  Future<MatchRoomEntity> createRoom({
    required UserEntity host,
    required List<String> invitedIds,
    required MatchFiltersEntity filters,
    required List<MatchCandidateEntity> candidates,
    required int? nextCandidatePage,
  }) async {
    final invited = invitedIds.where((id) => id != host.id).toSet().toList();
    final MatchRoomModel model;
    try {
      model = await _dataSource.createRoom(
        MatchRoomModel(
          id: '',
          hostId: host.id,
          participantIds: [host.id],
          invitedIds: invited,
          filters: filters,
          candidates: candidates,
          status: MatchRoomStatus.waiting,
          nextCandidatePage: nextCandidatePage,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      throw AppException(message: 'Erro ao criar sala.', cause: e);
    }

    // Não segura a abertura da sala esperando os avisos.
    unawaited(_notifyInvited(roomId: model.id, host: host, invitedIds: invited));
    return model.toEntity();
  }

  /// Melhor esforço: a sala já existe mesmo se algum aviso falhar.
  Future<void> _notifyInvited({
    required String roomId,
    required UserEntity host,
    required List<String> invitedIds,
  }) async {
    try {
      await _notifications.createMany([
        for (final userId in invitedIds)
          NotificationModel.fromActor(
            recipientId: userId,
            type: NotificationType.matchInvite,
            actor: host,
            roomId: roomId,
          ),
      ]);
    } catch (_) {}
  }

  @override
  Future<void> appendCandidates({
    required String roomId,
    required int fromPage,
    required List<MatchCandidateEntity> candidates,
    required int? nextPage,
  }) async {
    try {
      await _dataSource.appendCandidates(
        roomId: roomId,
        fromPage: fromPage,
        candidates: candidates,
        nextPage: nextPage,
      );
    } catch (e) {
      throw AppException(message: 'Erro ao buscar mais filmes.', cause: e);
    }
  }

  @override
  Future<void> joinRoom({required String roomId, required String userId}) async {
    try {
      await _dataSource.joinRoom(roomId: roomId, userId: userId);
    } catch (e) {
      throw AppException(message: 'Erro ao entrar na sala.', cause: e);
    }
  }

  @override
  Future<void> startSwiping(String roomId) {
    return _dataSource.startSwiping(roomId);
  }

  @override
  Future<void> submitSwipe({
    required String roomId,
    required String userId,
    required int tmdbMovieId,
    required bool liked,
  }) {
    return _dataSource.submitSwipe(
      roomId: roomId,
      userId: userId,
      tmdbMovieId: tmdbMovieId,
      liked: liked,
    );
  }

  @override
  Future<void> markMatched({required String roomId, required int tmdbMovieId}) {
    return _dataSource.markMatched(roomId: roomId, tmdbMovieId: tmdbMovieId);
  }
}
