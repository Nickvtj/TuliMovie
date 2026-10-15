import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifiers/user_search_notifier.dart';
import '../providers/social_providers.dart';
import '../widgets/user_list_tile.dart';

class UserSearchPage extends ConsumerWidget {
  const UserSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(userSearchNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TuliScreenHeader(
              mode: TuliScreenHeaderMode.stacked,
              title: 'Buscar pessoas',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TuliInputField(
                hint: '@usuario ou nome',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                textInputAction: TextInputAction.search,
                onChanged: ref.read(userSearchNotifierProvider.notifier).onQueryChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _SearchResults(state: search)),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.state});

  final UserSearchState state;

  @override
  Widget build(BuildContext context) {
    if (!state.hasQuery) {
      return const TuliEmptyState(
        message: 'Digite pelo menos 2 letras para encontrar amigos.',
        icon: Icons.person_search_rounded,
      );
    }
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: TuliFeedSkeleton(itemCount: 3),
      );
    }
    if (state.errorMessage != null) {
      return TuliEmptyState(message: state.errorMessage!, icon: Icons.error_outline_rounded);
    }
    if (state.results.isEmpty) {
      return const TuliEmptyState(
        message: 'Ninguém encontrado com esse nome.',
        icon: Icons.person_off_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      itemCount: state.results.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => UserListTile(user: state.results[index]),
    );
  }
}
