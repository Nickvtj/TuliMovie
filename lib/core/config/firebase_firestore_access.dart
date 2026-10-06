import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../errors/app_exception.dart';

/// Evita `FirebaseFirestore.instance` antes de [Firebase.initializeApp] (crítico na Web).
abstract final class FirebaseFirestoreAccess {
  static FirebaseFirestore? resolve({FirebaseFirestore? override}) {
    if (override != null) return override;
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  static FirebaseFirestore require({FirebaseFirestore? override}) {
    final db = resolve(override: override);
    if (db == null) {
      throw const AppException(
        message: 'Firebase não configurado. Rode: flutterfire configure',
        type: AppExceptionType.unknown,
      );
    }
    return db;
  }
}
