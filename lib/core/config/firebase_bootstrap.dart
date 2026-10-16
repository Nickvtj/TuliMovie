import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../notifications/push_notification_service.dart';
import 'firebase_options.dart';

bool _firebaseReady = false;

/// `true` após [Firebase.initializeApp] com sucesso.
///
/// Não usa `Firebase.apps`: na Web, antes do SDK JS carregar, o Safari lança
/// erro nessa chamada (o plugin só trata a mensagem do Chrome) e o app travava
/// na tela de carregamento no iPhone.
bool get isFirebaseReady => _firebaseReady;

/// Inicializa Firebase quando [DefaultFirebaseOptions] estiver configurado.
Future<void> bootstrapFirebase() async {
  if (_firebaseReady) return;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseReady = true;

    if (kIsWeb) {
      // Redes/bloqueadores que falham no WebChannel → long polling.
      FirebaseFirestore.instance.settings = const Settings(
        webExperimentalAutoDetectLongPolling: true,
      );
    }

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
  if (!isFirebaseReady) return;
  try {
    await service.initialize();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Push notifications não inicializadas: $e');
    }
  }
}
