import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/notifications/push_notification_service.dart';

/// Solicita push após login (importante para PWA iOS instalado na Tela de Início).
class PushPermissionPrompt extends ConsumerStatefulWidget {
  const PushPermissionPrompt({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushPermissionPrompt> createState() => _PushPermissionPromptState();
}

class _PushPermissionPromptState extends ConsumerState<PushPermissionPrompt> {
  bool _asked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
  }

  Future<void> _maybePrompt() async {
    if (_asked) return;
    _asked = true;

    if (!mounted) return;
    final accept = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ativar notificações?'),
          content: const Text(
            'Receba avisos quando a turma avaliar filmes, der match ou ativar o Selo da Discórdia.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Agora não')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ativar')),
          ],
        );
      },
    );

    if (accept == true) {
      await sl<PushNotificationService>().initialize();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
