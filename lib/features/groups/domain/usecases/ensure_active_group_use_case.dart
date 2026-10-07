import '../../../feed/data/datasources/review_firestore_data_source.dart';
import '../../../tools/data/datasources/watchlist_firestore_data_source.dart';
import '../../data/local/active_group_storage.dart';
import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

/// Garante turma ativa no dispositivo e migra reviews legadas sem [groupId].
class EnsureActiveGroupUseCase {
  EnsureActiveGroupUseCase({
    required GroupRepository groups,
    required ActiveGroupStorage storage,
    required ReviewFirestoreDataSource reviews,
    required WatchlistFirestoreDataSource watchlist,
  })  : _groups = groups,
        _storage = storage,
        _reviews = reviews,
        _watchlist = watchlist;

  final GroupRepository _groups;
  final ActiveGroupStorage _storage;
  final ReviewFirestoreDataSource _reviews;
  final WatchlistFirestoreDataSource _watchlist;

  Future<GroupEntity> call({required String userId, required String displayName}) async {
    final storedId = await _storage.read();
    if (storedId != null) {
      final existing = await _groups.getGroup(storedId);
      if (existing != null && existing.memberIds.contains(userId)) {
        await _migrateLegacy(storedId);
        return existing;
      }
    }

    final userGroups = await _groups.watchUserGroups(userId).first;
    if (userGroups.isNotEmpty) {
      final group = userGroups.first;
      await _storage.write(group.id);
      await _migrateLegacy(group.id);
      return group;
    }

    final created = await _groups.createGroup(
      name: 'Turma de $displayName',
      userId: userId,
    );
    await _storage.write(created.id);
    await _migrateLegacy(created.id);
    return created;
  }

  Future<void> _migrateLegacy(String groupId) async {
    await _reviews.migrateLegacyReviewsToGroup(groupId);
    await _reviews.backfillGroupIdsArray(groupId);
    await _watchlist.migrateLegacySharedItems(groupId);
  }
}
