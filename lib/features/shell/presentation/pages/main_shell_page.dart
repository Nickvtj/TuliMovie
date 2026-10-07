import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../discover/presentation/pages/discover_page.dart';
import '../../../feed/presentation/pages/feed_page.dart';
import '../../../feed/presentation/notifiers/feed_notifier.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../../../feed/presentation/providers/feed_read_providers.dart';
import '../../../groups/presentation/providers/group_providers.dart';
import '../../../movies/presentation/pages/movie_search_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../tools/presentation/pages/tools_hub_page.dart';

class MainShellPage extends ConsumerStatefulWidget {
  const MainShellPage({super.key});

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage> {
  int _index = 0;

  static const _pages = [
    FeedPage(),
    DiscoverPage(),
    MovieSearchPage(),
    ToolsHubPage(),
    ProfilePage(),
  ];

  void _onNavSelected(int index) {
    setState(() => _index = index);
    if (index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) markFeedAsSeen(ref);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(groupBootstrapProvider);
    final hasNewFeed = ref.watch(feedHasNewReviewsProvider);

    ref.listen<FeedState>(feedNotifierProvider, (previous, next) {
      if (_index != 0) return;
      if (previous?.isInitialLoading == true && !next.isInitialLoading) {
        markFeedAsSeen(ref);
      }
    });

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: TuliShellNavBar(
        selectedIndex: _index,
        onDestinationSelected: _onNavSelected,
        onPrimaryAction: () => _onNavSelected(TuliShellNavBar.primaryFabIndex),
        showFeedNotificationBadge: hasNewFeed && _index != 0,
      ),
    );
  }
}
