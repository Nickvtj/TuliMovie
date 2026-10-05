import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/firebase_bootstrap.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  await configureDependencies();
  runApp(const TuliMovieApp());
}
