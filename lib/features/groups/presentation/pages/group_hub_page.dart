import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../providers/group_providers.dart';

class GroupHubPage extends ConsumerStatefulWidget {
  const GroupHubPage({super.key});

  @override
  ConsumerState<GroupHubPage> createState() => _GroupHubPageState();
}

class _GroupHubPageState extends ConsumerState<GroupHubPage> {
  final _inviteController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _inviteController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(userGroupsProvider);
    final active = ref.watch(activeGroupProvider);
    final user = ref.watch(authSessionProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TuliScreenHeader(
              mode: TuliScreenHeaderMode.stacked,
              title: 'Minha turma',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  if (active != null)
                    TuliCard(
                      variant: TuliCardVariant.goldAccent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(active.name, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                            'Código: ${active.inviteCode}',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.gold,
                                  letterSpacing: 1.2,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TuliButton(
                            label: 'Copiar código',
                            icon: Icons.copy_rounded,
                            variant: TuliButtonVariant.secondary,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: active.inviteCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Código copiado!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Suas turmas', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  groups.when(
                    loading: () => const TuliFeedSkeleton(itemCount: 2),
                    error: (_, __) => const Text('Erro ao carregar turmas.'),
                    data: (items) {
                      if (items.isEmpty) {
                        return const Text('Nenhuma turma ainda.');
                      }
                      return Column(
                        children: items.map((group) {
                          final selected = group.id == ref.read(activeGroupIdProvider);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: TuliCard(
                              onTap: () async {
                                await ref.read(activeGroupStorageProvider).write(group.id);
                                ref.read(activeGroupIdProvider.notifier).state = group.id;
                                ref.invalidate(feedNotifierProvider);
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      group.name,
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ),
                                  if (selected)
                                    const Icon(Icons.check_circle, color: AppColors.gold, size: 20),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  TuliInputField(
                    label: 'Criar turma',
                    hint: 'Nome da turma',
                    controller: _nameController,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TuliButton(
                    label: 'Criar nova turma',
                    expand: true,
                    onPressed: user == null
                        ? null
                        : () async {
                            final name = _nameController.text.trim();
                            if (name.isEmpty) return;
                            final created = await ref.read(groupRepositoryProvider).createGroup(
                                  name: name,
                                  userId: user.id,
                                );
                            await ref.read(activeGroupStorageProvider).write(created.id);
                            ref.read(activeGroupIdProvider.notifier).state = created.id;
                            _nameController.clear();
                          },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TuliInputField(
                    label: 'Entrar com código',
                    hint: 'Ex: AB12CD',
                    controller: _inviteController,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TuliButton(
                    label: 'Entrar na turma',
                    variant: TuliButtonVariant.secondary,
                    expand: true,
                    onPressed: user == null
                        ? null
                        : () async {
                            final code = _inviteController.text.trim();
                            final joined = await ref.read(groupRepositoryProvider).joinByInviteCode(
                                  code: code,
                                  userId: user.id,
                                );
                            if (joined == null) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Código inválido.')),
                              );
                              return;
                            }
                            await ref.read(activeGroupStorageProvider).write(joined.id);
                            ref.read(activeGroupIdProvider.notifier).state = joined.id;
                            _inviteController.clear();
                          },
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
