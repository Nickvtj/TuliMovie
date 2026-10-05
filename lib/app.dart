import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/design_system/presentation/pages/design_system_showcase_page.dart';

class TuliMovieApp extends StatelessWidget {
  const TuliMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuliMovie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const DesignSystemShowcasePage(),
    );
  }
}
