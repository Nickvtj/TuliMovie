import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../shell/presentation/pages/main_shell_page.dart';
import '../services/auth_session_policy.dart';
import '../widgets/push_permission_prompt.dart';
import '../providers/auth_providers.dart';
import 'login_register_page.dart';

/// Session gate — login ou app autenticado.
class AuthGatePage extends ConsumerStatefulWidget {
  const AuthGatePage({super.key});

  @override
  ConsumerState<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends ConsumerState<AuthGatePage> {
  late final Future<void> _sessionPolicyFuture;

  @override
  void initState() {
    super.initState();
    _sessionPolicyFuture = enforceAuthSessionPolicy();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);

    return FutureBuilder<void>(
      future: _sessionPolicyFuture,
      builder: (context, policySnapshot) {
        if (policySnapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: TuliShimmerLoader(child: TuliShimmerBox(width: 120, height: 24)),
            ),
          );
        }

        return session.when(
          loading: () => const Scaffold(
            body: Center(
              child: TuliShimmerLoader(child: TuliShimmerBox(width: 120, height: 24)),
            ),
          ),
          error: (error, _) => const LoginRegisterPage(),
          data: (user) {
            if (user == null) return const LoginRegisterPage();
            return const PushPermissionPrompt(child: MainShellPage());
          },
        );
      },
    );
  }
}
