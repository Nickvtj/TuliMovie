import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../groups/presentation/pages/group_hub_page.dart';
import '../../../movie_match/presentation/pages/match_lobby_page.dart';
import 'watchlist_page.dart';

class ToolsHubPage extends StatelessWidget {
  const ToolsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            TuliSectionHeader(
              title: 'Dinâmicas',
              subtitle: 'Watchlist do grupo e match para decidir o filme da turma',
              trailingActions: [
                TuliIconButtonCircle(
                  icon: Icons.groups_rounded,
                  tooltip: 'Turma',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const GroupHubPage()),
                    );
                  },
                ),
              ],
            ),
            _ToolCard(
              icon: Icons.bookmark_outline,
              title: 'Watchlist do grupo',
              description: 'Filmes salvos para assistir juntos — com roleta integrada.',
              actionLabel: 'Abrir lista',
              onAction: (context) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const WatchlistPage()),
                );
              },
            ),
            _ToolCard(
              icon: Icons.favorite_border,
              title: 'Sala Match',
              description:
                  'Crie a sala, compartilhe o código com a turma ou jogue sozinho até alguém entrar.',
              actionLabel: 'Criar / entrar na sala',
              onAction: (context) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const MatchLobbyPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final void Function(BuildContext context)? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: TuliCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ToolIconBadge(icon: icon),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: TuliButton(
                  label: actionLabel!,
                  onPressed: () => onAction!(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToolIconBadge extends StatelessWidget {
  const _ToolIconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: AppShape.borderRadiusSm,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, color: AppColors.gold),
    );
  }
}
