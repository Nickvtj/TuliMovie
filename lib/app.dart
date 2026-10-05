import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/auth_gate_page.dart';

class TuliMovieApp extends StatelessWidget {
  const TuliMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuliMovie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthGatePage(),
    );
  }
}
