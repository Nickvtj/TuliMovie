import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../discover/presentation/pages/discover_page.dart';
import '../../../feed/presentation/pages/feed_page.dart';
import '../../../feed/presentation/notifiers/feed_notifier.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../../../feed/presentation/providers/feed_read_providers.dart';
import '../../../movies/presentation/pages/movie_search_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../movie_match/presentation/pages/match_lobby_page.dart';

class MainShellPage extends ConsumerStatefulWidget {
  const MainShellPage({super.key});

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage> {
  int _index = 0;

  /// Abas já abertas. Cada aba só é montada (e busca dados) na primeira visita,
  /// em vez de todas carregarem juntas logo após o login.
  final Set<int> _visited = {0};

  static const _pages = [
    FeedPage(),
    DiscoverPage(),
    MovieSearchPage(),
    MatchLobbyPage(),
    ProfilePage(),
  ];

  void _onNavSelected(int index) {
    setState(() {
      _index = index;
      _visited.add(index);
    });
    if (index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) markFeedAsSeen(ref);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        children: [
          for (var i = 0; i < _pages.length; i++)
            _visited.contains(i) ? _pages[i] : const SizedBox.shrink(),
        ],
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
