import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../config/env_config.dart';

/// Web Push (PWA iOS 16.4+) + Android via FCM.
class PushNotificationService {
  PushNotificationService({FirebaseMessaging? messaging}) : _messagingOverride = messaging;

  final FirebaseMessaging? _messagingOverride;

  FirebaseMessaging? get _messaging {
    if (_messagingOverride != null) return _messagingOverride;
    if (Firebase.apps.isEmpty) return null;
    return FirebaseMessaging.instance;
  }

  Future<void> initialize() async {
    final messaging = _messaging;
    if (messaging == null) return;

    if (kIsWeb && !EnvConfig.hasFcmVapidKey) {
      if (kDebugMode) {
        debugPrint('FCM: defina --dart-define=FCM_VAPID_KEY=... para Web Push.');
      }
      return;
    }

    try {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      if (kIsWeb && EnvConfig.hasFcmVapidKey) {
        await messaging.getToken(vapidKey: EnvConfig.fcmVapidKey);
      } else {
        await messaging.getToken();
      }

      FirebaseMessaging.onMessage.listen((message) {
        if (kDebugMode) {
          debugPrint('FCM foreground: ${message.notification?.title}');
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (kDebugMode) {
          debugPrint('FCM opened: ${message.data}');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM init falhou: $e');
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('FCM background: ${message.messageId}');
  }
}
