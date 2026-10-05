import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/theme.dart';

/// Página temporária da Fase 1 — valida theme + widgets core (remover quando houver auth/feed).
class DesignSystemShowcasePage extends StatefulWidget {
  const DesignSystemShowcasePage({
    super.key,
    this.userDisplayName,
    this.onSignOut,
  });

  final String? userDisplayName;
  final VoidCallback? onSignOut;

  @override
  State<DesignSystemShowcasePage> createState() => _DesignSystemShowcasePageState();
}

class _DesignSystemShowcasePageState extends State<DesignSystemShowcasePage> {
  double _rating = 3.5;
  bool _loadingDemo = false;

  static String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final token = parts.first;
      return (token.length >= 2 ? token.substring(0, 2) : token).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundVignette),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: Text('TuliMovie', style: textTheme.headlineSmall),
                actions: [
                  if (widget.onSignOut != null)
                    IconButton(
                      tooltip: 'Sair',
                      onPressed: widget.onSignOut,
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: UserAvatarGroup(
                      imageUrls: const [null, null, null],
                      initials: [
                        _initialsFromName(widget.userDisplayName ?? 'NV'),
                        'AM',
                        'JP',
                      ],
                      size: 32,
                    ),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text('Design System', style: textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Fase 1 — core/theme + core/presentation/widgets',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    TuliCard(
                      variant: TuliCardVariant.goldAccent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Avaliação', style: textTheme.titleMedium),
                          const SizedBox(height: 12),
                          TuliRatingStars(
                            value: _rating,
                            allowHalfStars: true,
                            onChanged: (v) => setState(() => _rating = v),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_rating.toStringAsFixed(1)} ★',
                            style: textTheme.bodyLarge?.copyWith(color: AppColors.gold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TuliInputField(
                      label: 'E-mail',
                      hint: 'voce@turma.com',
                      prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        TuliButton(
                          label: 'Primário',
                          icon: Icons.movie_outlined,
                          onPressed: () {},
                        ),
                        TuliButton(
                          label: 'Secundário',
                          variant: TuliButtonVariant.secondary,
                          onPressed: () {},
                        ),
                        TuliButton(
                          label: 'Loading',
                          isLoading: _loadingDemo,
                          onPressed: () {
                            setState(() => _loadingDemo = true);
                            Future<void>.delayed(const Duration(seconds: 2), () {
                              if (mounted) setState(() => _loadingDemo = false);
                            });
                          },
                        ),
                        TuliButton(
                          label: 'Selo da Discórdia',
                          variant: TuliButtonVariant.destructive,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TuliCard(
                      variant: TuliCardVariant.alert,
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: AppColors.neonRed),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Alerta neon — polêmica na sessão em grupo.',
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Skeleton feed', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    const TuliFeedSkeleton(itemCount: 2),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
