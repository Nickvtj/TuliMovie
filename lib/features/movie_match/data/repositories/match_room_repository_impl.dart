import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/match_candidate_entity.dart';
import '../../domain/entities/match_filters_entity.dart';
import '../../domain/entities/match_room_entity.dart';
import '../../domain/repositories/match_room_repository.dart';
import '../datasources/match_room_firestore_data_source.dart';
import '../models/match_room_model.dart';

class MatchRoomRepositoryImpl implements MatchRoomRepository {
  MatchRoomRepositoryImpl(this._dataSource);

  final MatchRoomFirestoreDataSource _dataSource;

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
    required String hostId,
    required List<String> participantIds,
    required MatchFiltersEntity filters,
    required List<MatchCandidateEntity> candidates,
  }) async {
    try {
      final uniqueParticipants = {hostId, ...participantIds}.toList();
      final model = await _dataSource.createRoom(
        MatchRoomModel(
          id: '',
          hostId: hostId,
          participantIds: uniqueParticipants,
          filters: filters,
          candidates: candidates,
          status: MatchRoomStatus.waiting,
          createdAt: DateTime.now(),
        ),
      );
      return model.toEntity();
    } catch (e) {
      throw AppException(message: 'Erro ao criar sala.', cause: e);
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

  @override
  Future<MatchRoomEntity?> findRoomByShortCode(String shortCode) async {
    final model = await _dataSource.findRoomByShortCode(shortCode);
    return model?.toEntity();
  }
}
