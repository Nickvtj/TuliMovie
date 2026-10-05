import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../notifications/push_notification_service.dart';
import 'firebase_options.dart';

/// Inicializa Firebase quando [DefaultFirebaseOptions] estiver configurado.
Future<void> bootstrapFirebase() async {
  if (Firebase.apps.isNotEmpty) return;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase não configurado (ok na Fase 2): $e');
    }
  }
}

Future<void> bootstrapPushNotifications(PushNotificationService service) async {
  if (Firebase.apps.isEmpty) return;
  try {
    await service.initialize();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Push notifications não inicializadas: $e');
    }
  }
}
