import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/firebase_bootstrap.dart';
import 'core/di/injection.dart';
import 'core/notifications/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  await configureDependencies();
  await bootstrapPushNotifications(sl<PushNotificationService>());
  runApp(
    const ProviderScope(
      child: TuliMovieApp(),
    ),
  );
}
