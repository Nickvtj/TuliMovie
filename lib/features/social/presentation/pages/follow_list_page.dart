import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../providers/social_providers.dart';
import '../widgets/user_list_tile.dart';

enum FollowListTab { followers, following }

/// Abas Seguidores / Seguindo de um perfil.
class FollowListPage extends StatelessWidget {
  const FollowListPage({
    super.key,
    required this.userId,
    this.initialTab = FollowListTab.followers,
  });

  final String userId;
  final FollowListTab initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: FollowListTab.values.length,
      initialIndex: initialTab.index,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const TuliScreenHeader(
                mode: TuliScreenHeaderMode.stacked,
                title: 'Conexões',
              ),
              const TabBar(
                indicatorColor: AppColors.gold,
                labelColor: AppColors.gold,
                unselectedLabelColor: AppColors.textMuted,
                tabs: [
                  Tab(text: 'Seguidores'),
                  Tab(text: 'Seguindo'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _UserList(
                      users: followersProvider(userId),
                      emptyMessage: 'Ninguém segue ainda.',
                    ),
                    _UserList(
                      users: followingProvider(userId),
                      emptyMessage: 'Ainda não segue ninguém.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserList extends ConsumerWidget {
  const _UserList({required this.users, required this.emptyMessage});

  final ProviderListenable<AsyncValue<List<UserEntity>>> users;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(users).when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: TuliFeedSkeleton(itemCount: 3),
          ),
          error: (e, _) => const TuliEmptyState(
            message: 'Não foi possível carregar a lista.',
            icon: Icons.error_outline_rounded,
          ),
          data: (items) {
            if (items.isEmpty) {
              return TuliEmptyState(message: emptyMessage, icon: Icons.people_outline_rounded);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) => UserListTile(user: items[index]),
            );
          },
        );
  }
}
