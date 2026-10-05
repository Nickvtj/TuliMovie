import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../awards/presentation/pages/tuli_awards_page.dart';
import '../providers/profile_providers.dart';

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final token = parts.first;
    return (token.length >= 2 ? token.substring(0, 2) : token).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(profileDashboardProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: dashboard.when(
          loading: () => const Center(child: TuliFeedSkeleton(itemCount: 4)),
          error: (e, _) => Center(child: Text('Erro no perfil: $e')),
          data: (data) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.displayName, style: textTheme.headlineSmall),
                          const SizedBox(height: 4),
                          Text(
                            data.cinephileLabel,
                            style: textTheme.labelLarge?.copyWith(color: AppColors.gold),
                          ),
                        ],
                      ),
                    ),
                    TuliAvatar(size: 56, initials: _initials(data.displayName)),
                  ],
                ),
                const SizedBox(height: 16),
                TuliCard(
                  variant: TuliCardVariant.goldAccent,
                  child: Row(
                    children: [
                      const Icon(Icons.timelapse, color: AppColors.gold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Filômetro', style: textTheme.labelMedium),
                            Text(
                              '${data.filometerHours.toStringAsFixed(1)} horas de filme',
                              style: textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Top 4 da vida', style: textTheme.titleMedium),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    if (index >= data.top4.length) {
                      return TuliCard(
                        child: Center(
                          child: Text('Slot ${index + 1}', style: textTheme.bodySmall),
                        ),
                      );
                    }
                    final slot = data.top4[index];
                    return TuliCard(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TuliPosterImage(
                              posterPath: slot.posterPath,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slot.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelMedium,
                          ),
                          Text(
                            '${slot.userRating.toStringAsFixed(1)}★',
                            style: textTheme.labelSmall?.copyWith(color: AppColors.gold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text('Conquistas', style: textTheme.titleMedium),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: data.badges.length,
                  itemBuilder: (context, index) {
                    final badge = data.badges[index];
                    return TuliCard(
                      variant: badge.unlocked
                          ? TuliCardVariant.goldAccent
                          : TuliCardVariant.standard,
                      child: Opacity(
                        opacity: badge.unlocked ? 1 : 0.45,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${badge.emoji} ${badge.title}',
                                style: textTheme.labelLarge),
                            const SizedBox(height: 4),
                            Text(badge.description, style: textTheme.bodySmall),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                TuliButton(
                  label: 'Abrir Tuli Awards',
                  icon: Icons.emoji_events_outlined,
                  expand: true,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const TuliAwardsPage()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
