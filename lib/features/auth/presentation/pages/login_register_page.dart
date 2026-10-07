import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/firebase_bootstrap.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifiers/auth_form_notifier.dart';
import '../providers/auth_providers.dart';
import '../state/auth_form_state.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_logo_header.dart';
import '../widgets/auth_mode_toggle.dart';
import '../widgets/auth_pill_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_tokens.dart';
import '../widgets/firebase_auth_setup_help.dart';

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
      backgroundColor: AuthTokens.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AuthBackground(step: form.step),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 520
            ? AuthTokens.maxContentWidth
            : constraints.maxWidth;

        final actionsWidth = maxWidth > AuthTokens.welcomeActionsMaxWidth
            ? AuthTokens.welcomeActionsMaxWidth
            : maxWidth;

        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(child: SizedBox.shrink()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AuthTokens.horizontalPadding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: const AuthWelcomeHero(),
                  ),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AuthTokens.horizontalPadding),
                  child: SizedBox(
                    width: actionsWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthPillButton(
                          label: 'Entrar',
                          showArrow: true,
                          solidPrimary: true,
                          borderRadius: AuthTokens.welcomeButtonRadius,
                          onPressed: onLogin,
                        ),
                        const SizedBox(height: 12),
                        AuthPillButton(
                          label: 'Criar conta',
                          variant: AuthPillButtonVariant.welcomeSecondary,
                          icon: Icons.person_add_alt_1_outlined,
                          borderRadius: AuthTokens.welcomeButtonRadius,
                          onPressed: onRegister,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (!isFirebaseReady) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AuthTokens.horizontalPadding),
                    child: Text(
                      'Firebase não configurado — configure para login e feed.',
                      style: TextStyle(fontSize: 12, color: AppColors.neonRed),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AuthTokens.horizontalPadding),
                  child: Text(
                    'Junte-se à comunidade cinéfila do TuliMovie.',
                    style: AuthTokens.welcomeFooter,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
            const Positioned(
              top: 4,
              left: AuthTokens.horizontalPadding,
              child: AuthWelcomeStatusDot(),
            ),
          ],
        );
      },
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
    final isRegister = form.isRegister;
    final screenH = MediaQuery.sizeOf(context).height;
    final headerH = screenH * 0.14;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) notifier.backToWelcome();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AuthTokens.horizontalPadding,
              8,
              AuthTokens.horizontalPadding,
              24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AuthTokens.maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: headerH,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedSwitcher(
                              duration: AppDurations.fast,
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              layoutBuilder: (current, _) =>
                                  current ?? const SizedBox.shrink(),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              child: Text(
                                isRegister ? 'Cadastro' : 'Entrar',
                                key: ValueKey<bool>(isRegister),
                                style: AuthTokens.credentialsTitle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedSwitcher(
                              duration: AppDurations.fast,
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              layoutBuilder: (current, _) =>
                                  current ?? const SizedBox.shrink(),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              child: Text(
                                isRegister
                                    ? 'Junte-se à turma em segundos'
                                    : 'Bem-vindo de volta ao cinema',
                                key: ValueKey<String>(
                                  isRegister ? 'sub_register' : 'sub_login',
                                ),
                                style: AuthTokens.credentialsSubtitle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AuthModeToggle(
                        isRegister: isRegister,
                        onChanged: (register) {
                          if (register != isRegister) notifier.toggleMode();
                        },
                      ),
                      const SizedBox(height: 16),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AuthTokens.surfaceCard,
                          borderRadius: BorderRadius.circular(AuthTokens.cardRadius),
                          border: Border.all(color: AuthTokens.cardBorder),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AnimatedSize(
                                duration: AppDurations.normal,
                                curve: Curves.easeInOutCubic,
                                alignment: Alignment.topCenter,
                                child: _CredentialFields(
                                  form: form,
                                  notifier: notifier,
                                  isRegister: isRegister,
                                ),
                              ),
                              if (_needsFirebaseAuthSetupHelp(form.formError)) ...[
                                const SizedBox(height: 12),
                                const FirebaseAuthSetupHelp(),
                              ] else if (form.formError != null) ...[
                                const SizedBox(height: 12),
                                _FormErrorBanner(message: form.formError!),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AuthPillButton(
                        label: isRegister ? 'Criar conta' : 'Entrar no Cinema',
                        showArrow: true,
                        borderRadius: AuthTokens.buttonRadius,
                        isLoading: form.isSubmitting,
                        onPressed: form.canSubmit
                            ? () async {
                                await notifier.submit();
                              }
                            : null,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => notifier.toggleMode(),
                        child: Text.rich(
                          TextSpan(
                            style: AuthTokens.footerLink,
                            children: [
                              TextSpan(
                                text: isRegister ? 'Já faz parte? ' : 'Ainda não faz parte? ',
                              ),
                              TextSpan(
                                text: isRegister ? 'Entrar agora' : 'Criar conta agora',
                                style: AuthTokens.footerLinkAccent,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Expande/recolhe seções sem trocar o formulário inteiro (evita “fantasma” no fade).
class _AuthExpandSection extends StatelessWidget {
  const _AuthExpandSection({required this.show, required this.child});

  final bool show;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedAlign(
        duration: AppDurations.normal,
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topCenter,
        heightFactor: show ? 1 : 0,
        child: AnimatedOpacity(
          duration: AppDurations.fast,
          curve: Curves.easeOut,
          opacity: show ? 1 : 0,
          child: child,
        ),
      ),
    );
  }
}

class _CredentialFields extends StatelessWidget {
  const _CredentialFields({
    required this.form,
    required this.notifier,
    required this.isRegister,
  });

  final AuthFormState form;
  final AuthFormNotifier notifier;
  final bool isRegister;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AuthExpandSection(
          show: isRegister,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                label: 'Nome',
                hint: 'Como a turma te chama?',
                errorText: form.displayNameError,
                textInputAction: TextInputAction.next,
                prefixIcon:
                    const Icon(Icons.person_outline, color: AuthTokens.textMuted, size: 22),
                onChanged: notifier.onDisplayNameChanged,
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        AuthTextField(
          label: 'E-mail',
          hint: 'voce@turma.com',
          errorText: form.emailError,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          prefixIcon: const Icon(Icons.mail_outline, color: AuthTokens.textMuted, size: 22),
          onChanged: notifier.onEmailChanged,
        ),
        const SizedBox(height: 14),
        AuthTextField(
          label: 'Senha',
          hint: isRegister ? 'Mínimo 6 caracteres' : '••••••••',
          errorText: form.passwordError,
          obscureText: true,
          autofillHints: isRegister
              ? const [AutofillHints.newPassword]
              : const [AutofillHints.password],
          prefixIcon: const Icon(Icons.lock_outline, color: AuthTokens.textMuted, size: 22),
          onChanged: notifier.onPasswordChanged,
        ),
        _AuthExpandSection(
          show: !isRegister,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  Transform.scale(
                    scale: 0.82,
                    child: Switch(
                      value: form.rememberMe,
                      onChanged: notifier.onRememberMeChanged,
                      activeThumbColor: AuthTokens.background,
                      activeTrackColor: AuthTokens.primaryYellow,
                      inactiveThumbColor: AuthTokens.textMuted,
                      inactiveTrackColor: AuthTokens.inputBorder,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => notifier.onRememberMeChanged(!form.rememberMe),
                      child: const Text(
                        'Lembrar de mim por 30 dias',
                        style: AuthTokens.rememberMe,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _AuthExpandSection(
          show: isRegister,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 14),
              AuthTextField(
                label: 'Confirmar senha',
                hint: 'Repita a senha',
                errorText: form.confirmPasswordError,
                obscureText: true,
                prefixIcon:
                    const Icon(Icons.shield_outlined, color: AuthTokens.textMuted, size: 22),
                onChanged: notifier.onConfirmPasswordChanged,
              ),
            ],
          ),
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
              style: const TextStyle(fontSize: 12, color: AuthTokens.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
