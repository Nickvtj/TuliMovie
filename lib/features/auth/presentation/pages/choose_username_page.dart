import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../utils/auth_validators.dart';

/// Exibida pelo gate quando o perfil logado ainda não tem @username.
class ChooseUsernamePage extends ConsumerStatefulWidget {
  const ChooseUsernamePage({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<ChooseUsernamePage> createState() => _ChooseUsernamePageState();
}

class _ChooseUsernamePageState extends ConsumerState<ChooseUsernamePage> {
  final _controller = TextEditingController();
  String? _error;
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final validation = AuthValidators.username(_controller.text);
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await ref.read(claimUsernameUseCaseProvider).call(
            userId: widget.userId,
            username: _controller.text,
          );
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const TuliScreenHeader(
              title: 'Escolha seu @',
              subtitle: 'É assim que seus amigos vão te encontrar.',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TuliInputField(
                    controller: _controller,
                    label: 'Usuário',
                    hint: 'seu.usuario',
                    errorText: _error,
                    prefixIcon: const Icon(Icons.alternate_email, color: AppColors.textMuted),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TuliButton(
                    label: 'Continuar',
                    expand: true,
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TuliButton(
                    label: 'Sair da conta',
                    icon: Icons.logout_rounded,
                    expand: true,
                    variant: TuliButtonVariant.ghost,
                    onPressed: () => ref.read(signOutUseCaseProvider)(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
