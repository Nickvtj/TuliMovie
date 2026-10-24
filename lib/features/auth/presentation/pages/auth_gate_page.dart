import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../shell/presentation/pages/main_shell_page.dart';
import '../services/auth_session_policy.dart';
import '../providers/auth_providers.dart';
import 'choose_username_page.dart';
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
            return _UsernameGate(userId: user.id);
          },
        );
      },
    );
  }
}

/// Garante @username antes do shell. Durante o cadastro o @ é reservado logo
/// após a sessão abrir, então aguarda o submit terminar antes de pedir o @.
class _UsernameGate extends ConsumerWidget {
  const _UsernameGate({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider(userId));
    final isSubmitting = ref.watch(authFormNotifierProvider.select((s) => s.isSubmitting));
    const shell = MainShellPage();

    if (profile.valueOrNull?.hasUsername ?? false) return shell;
    // Firestore indisponível: mantém o fallback offline do app.
    if (profile.hasError) return shell;
    if (profile.isLoading || isSubmitting) {
      return const Scaffold(
        body: Center(
          child: TuliShimmerLoader(child: TuliShimmerBox(width: 120, height: 24)),
        ),
      );
    }
    return ChooseUsernamePage(userId: userId);
  }
}
