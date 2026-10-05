import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../shell/presentation/pages/main_shell_page.dart';
import '../widgets/push_permission_prompt.dart';
import '../providers/auth_providers.dart';
import 'login_register_page.dart';

/// Session gate — login ou app autenticado.
class AuthGatePage extends ConsumerWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);

    return session.when(
      loading: () => const Scaffold(
        body: Center(child: TuliShimmerLoader(child: TuliShimmerBox(width: 120, height: 24))),
      ),
      error: (error, _) => const LoginRegisterPage(),
      data: (user) {
        if (user == null) return const LoginRegisterPage();
        return const PushPermissionPrompt(child: MainShellPage());
      },
    );
  }
}
