import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/tuli_card.dart';
import '../../../../core/theme/app_colors.dart';

/// Passos do Console quando Auth retorna `configuration-not-found`.
class FirebaseAuthSetupHelp extends StatelessWidget {
  const FirebaseAuthSetupHelp({super.key});

  static const _authUrl =
      'https://console.firebase.google.com/project/tulimovie/authentication';
  static const _providersUrl =
      'https://console.firebase.google.com/project/tulimovie/authentication/providers';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TuliCard(
      variant: TuliCardVariant.alert,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ativar cadastro no Firebase (1x)',
            style: textTheme.titleSmall?.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: 10),
          _Step(
            number: 1,
            text: 'Abra Authentication e clique em Começar',
            url: _authUrl,
          ),
          const SizedBox(height: 8),
          _Step(
            number: 2,
            text: 'Sign-in method → E-mail/senha → Ativar → Salvar',
            url: _providersUrl,
          ),
          const SizedBox(height: 8),
          Text(
            'Depois: hot restart (R) e tente Criar conta de novo.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.text,
    required this.url,
  });

  final int number;
  final String text;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: AppColors.gold.withValues(alpha: 0.2),
          child: Text(
            '$number',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.gold),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: Theme.of(context).textTheme.bodySmall),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copiado — cole no navegador'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  'Copiar link do passo $number',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.gold,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
