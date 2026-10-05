import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

/// Inicializa Firebase quando [DefaultFirebaseOptions] estiver configurado.
Future<void> bootstrapFirebase() async {
  if (Firebase.apps.isNotEmpty) return;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase não configurado (ok na Fase 2): $e');
    }
  }
}
