import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Placeholder — substitua rodando `flutterfire configure`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Configure o Firebase com: dart pub global activate flutterfire_cli && flutterfire configure',
    );
  }

  static FirebaseOptions get web => currentPlatform;
  static FirebaseOptions get android => currentPlatform;
  static FirebaseOptions get ios => currentPlatform;
}
