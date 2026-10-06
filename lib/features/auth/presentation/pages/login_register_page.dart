import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/firebase_bootstrap.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifiers/auth_form_notifier.dart';
import '../providers/auth_providers.dart';
import '../state/auth_form_state.dart';
import '../widgets/auth_cinematic_backdrop.dart';
import '../widgets/firebase_auth_setup_help.dart';
import '../widgets/glass_auth_panel.dart';

bool _needsFirebaseAuthSetupHelp(String? formError) {
  if (formError == null) return false;
  final lower = formError.toLowerCase();
  return lower.contains('configuration-not-found') ||
      lower.contains('authentication ainda não foi ativado') ||
      lower.contains('e-mail/senha');
}

class LoginRegisterPage extends ConsumerWidget {
  const LoginRegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(authFormNotifierProvider);
    final notifier = ref.read(authFormNotifierProvider.notifier);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthCinematicBackdrop(),
          SafeArea(
            child: AnimatedSwitcher(
              duration: AppDurations.normal,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: form.isWelcome
                  ? _AuthWelcomeView(
                      key: const ValueKey('welcome'),
                      onLogin: notifier.openLogin,
                      onRegister: notifier.openRegister,
                    )
                  : _AuthCredentialsView(
                      key: const ValueKey('credentials'),
                      form: form,
                      notifier: notifier,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthWelcomeView extends StatelessWidget {
  const _AuthWelcomeView({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_movies_rounded, size: 72, color: AppColors.gold.withValues(alpha: 0.9)),
                const SizedBox(height: 24),
                Text(
                  'TuliMovie',
                  style: textTheme.displaySmall?.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'O cinema da turma, num só lugar.',
                  style: textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Avalie filmes, reaja no feed e descubra o próximo filme juntos.',
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                if (!isFirebaseReady) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Firebase não configurado — configure para login e feed.',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.neonRed),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TuliButton(label: 'Entrar', expand: true, onPressed: onLogin),
                const SizedBox(height: 12),
                TuliButton(
                  label: 'Criar conta',
                  expand: true,
                  variant: TuliButtonVariant.secondary,
                  onPressed: onRegister,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthCredentialsView extends StatelessWidget {
  const _AuthCredentialsView({
    super.key,
    required this.form,
    required this.notifier,
  });

  final AuthFormState form;
  final AuthFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: notifier.backToWelcome,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Voltar',
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: GlassAuthPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        form.isRegister ? 'Cadastro' : 'Entrar',
                        style: textTheme.headlineMedium?.copyWith(color: AppColors.gold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        form.isRegister
                            ? 'Junte-se à turma em segundos'
                            : 'Bem-vindo de volta ao cinema',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _ModeToggle(
                        isRegister: form.isRegister,
                        onChanged: (register) {
                          if (register != form.isRegister) notifier.toggleMode();
                        },
                      ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: AppDurations.normal,
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.04),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: form.isRegister
                            ? _RegisterFields(
                                key: const ValueKey('register'),
                                form: form,
                                notifier: notifier,
                              )
                            : _LoginFields(
                                key: const ValueKey('login'),
                                form: form,
                                notifier: notifier,
                              ),
                      ),
                      if (_needsFirebaseAuthSetupHelp(form.formError)) ...[
                        const SizedBox(height: 12),
                        const FirebaseAuthSetupHelp(),
                      ] else if (form.formError != null) ...[
                        const SizedBox(height: 12),
                        _FormErrorBanner(message: form.formError!),
                      ],
                      const SizedBox(height: 20),
                      TuliButton(
                        label: form.isRegister ? 'Criar conta' : 'Entrar',
                        expand: true,
                        isLoading: form.isSubmitting,
                        onPressed: form.canSubmit
                            ? () async {
                                await notifier.submit();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.isRegister,
    required this.onChanged,
  });

  final bool isRegister;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.8),
        borderRadius: AppShape.borderRadiusMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              label: 'Entrar',
              selected: !isRegister,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ModeChip(
              label: 'Cadastro',
              selected: isRegister,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? AppColors.gold.withValues(alpha: 0.18) : Colors.transparent,
        borderRadius: AppShape.borderRadiusSm,
        border: selected
            ? Border.all(color: AppColors.gold.withValues(alpha: 0.45))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppShape.borderRadiusSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? AppColors.gold : AppColors.textSecondary,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginFields extends StatelessWidget {
  const _LoginFields({
    super.key,
    required this.form,
    required this.notifier,
  });

  final AuthFormState form;
  final AuthFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TuliInputField(
          label: 'E-mail',
          hint: 'voce@turma.com',
          errorText: form.emailError,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textMuted),
          onChanged: notifier.onEmailChanged,
        ),
        const SizedBox(height: 14),
        TuliInputField(
          label: 'Senha',
          hint: '••••••••',
          errorText: form.passwordError,
          obscureText: form.obscurePassword,
          autofillHints: const [AutofillHints.password],
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
          onChanged: notifier.onPasswordChanged,
        ),
      ],
    );
  }
}

class _RegisterFields extends StatelessWidget {
  const _RegisterFields({
    super.key,
    required this.form,
    required this.notifier,
  });

  final AuthFormState form;
  final AuthFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TuliInputField(
          label: 'Nome',
          hint: 'Como a turma te chama?',
          errorText: form.displayNameError,
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMuted),
          onChanged: notifier.onDisplayNameChanged,
        ),
        const SizedBox(height: 14),
        TuliInputField(
          label: 'E-mail',
          hint: 'voce@turma.com',
          errorText: form.emailError,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textMuted),
          onChanged: notifier.onEmailChanged,
        ),
        const SizedBox(height: 14),
        TuliInputField(
          label: 'Senha',
          hint: 'Mínimo 6 caracteres',
          errorText: form.passwordError,
          obscureText: form.obscurePassword,
          autofillHints: const [AutofillHints.newPassword],
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
          onChanged: notifier.onPasswordChanged,
        ),
        const SizedBox(height: 14),
        TuliInputField(
          label: 'Confirmar senha',
          hint: 'Repita a senha',
          errorText: form.confirmPasswordError,
          obscureText: form.obscureConfirmPassword,
          prefixIcon: const Icon(Icons.verified_user_outlined, color: AppColors.textMuted),
          onChanged: notifier.onConfirmPasswordChanged,
        ),
      ],
    );
  }
}

class _FormErrorBanner extends StatelessWidget {
  const _FormErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return TuliCard(
      variant: TuliCardVariant.alert,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.neonRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
