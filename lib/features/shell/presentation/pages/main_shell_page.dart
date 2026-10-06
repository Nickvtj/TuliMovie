import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../discover/presentation/pages/discover_page.dart';
import '../../../feed/presentation/pages/feed_page.dart';
import '../../../movies/presentation/pages/movie_search_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../tools/presentation/pages/tools_hub_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: TuliShellNavBar(
        selectedIndex: _index,
        onDestinationSelected: _onNavSelected,
        onPrimaryAction: () => _onNavSelected(TuliShellNavBar.primaryFabIndex),
      ),
    );
  }
}
