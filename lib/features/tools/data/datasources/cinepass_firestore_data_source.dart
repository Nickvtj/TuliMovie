import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_firestore_access.dart';
import '../../domain/entities/cinepass_entity.dart';

class CinepassFirestoreDataSource {
  CinepassFirestoreDataSource({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestoreAccess.require(override: _firestoreOverride)
          .collection('cinepass')
          .doc('queue');

  Stream<CinepassStateEntity> watchState() {
    return _doc.snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return const CinepassStateEntity(queue: [], currentIndex: 0);
      }

      final data = snap.data()!;
      final entriesRaw = data['entries'] as List<dynamic>? ?? [];
      final entries = entriesRaw
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => CinepassEntryEntity(
              userId: item['userId'] as String? ?? '',
              displayName: item['displayName'] as String? ?? '',
            ),
          )
          .toList();

      return CinepassStateEntity(
        queue: entries,
        currentIndex: (data['currentIndex'] as num?)?.toInt() ?? 0,
      );
    });
  }
}
