import 'package:cloud_firestore/cloud_firestore.dart';

class AwardsFirestoreDataSource {
  AwardsFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _yearDoc(int year) =>
      _firestore.collection('awards').doc(year.toString());

  Future<void> voteComicCategory({
    required int year,
    required String categoryId,
    required String userId,
    required String choiceText,
  }) async {
    await _yearDoc(year).collection('votes').doc('${categoryId}_$userId').set({
      'categoryId': categoryId,
      'userId': userId,
      'choiceText': choiceText,
      'votedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, String>> fetchVotesForYear(int year) async {
    final snapshot = await _yearDoc(year).collection('votes').get();
    final map = <String, String>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      map[data['categoryId'] as String? ?? doc.id] = data['choiceText'] as String? ?? '';
    }
    return map;
  }
}
