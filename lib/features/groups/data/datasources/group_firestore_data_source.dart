import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_firestore_access.dart';
import '../models/group_model.dart';

class GroupFirestoreDataSource {
  GroupFirestoreDataSource({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  static const collectionPath = 'groups';

  CollectionReference<Map<String, dynamic>> get _groups =>
      FirebaseFirestoreAccess.require(override: _firestoreOverride).collection(collectionPath);

  String _randomInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<GroupModel> createGroup({
    required String name,
    required String createdBy,
    List<String> initialMemberIds = const [],
  }) async {
    final members = {createdBy, ...initialMemberIds}.toList();
    final ref = _groups.doc();
    final model = GroupModel(
      id: ref.id,
      name: name,
      inviteCode: _randomInviteCode(),
      memberIds: members,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );
    await ref.set(model.toJson());
    return model;
  }

  Future<GroupModel?> findByInviteCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    final snap = await _groups.where('inviteCode', isEqualTo: normalized).limit(1).get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return GroupModel.fromJson(doc.id, doc.data());
  }

  Future<GroupModel?> getGroup(String groupId) async {
    final snap = await _groups.doc(groupId).get();
    if (!snap.exists || snap.data() == null) return null;
    return GroupModel.fromJson(snap.id, snap.data()!);
  }

  Future<void> addMember({required String groupId, required String userId}) async {
    await _groups.doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  Stream<List<GroupModel>> watchGroupsForUser(String userId) {
    return _groups.where('memberIds', arrayContains: userId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => GroupModel.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }
}
