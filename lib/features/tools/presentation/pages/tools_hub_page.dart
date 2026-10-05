import 'package:flutter/material.dart';

import '../../../movie_match/presentation/pages/match_lobby_page.dart';
import '../widgets/cinepass_widget.dart';
import '../widgets/movie_roulette_widget.dart';

class ToolsHubPage extends StatelessWidget {
  const ToolsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Dinâmicas da turma', style: textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Cinepass', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            const CinepassWidget(),
            const SizedBox(height: 24),
            Text('Roleta da Watchlist', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            const MovieRouletteWidget(),
            const SizedBox(height: 24),
            Text('Tinder do Cinema', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const MatchLobbyPage()),
                );
              },
              icon: const Icon(Icons.favorite_border),
              label: const Text('Criar / entrar na sala de match'),
            ),
          ],
        ),
      ),
    );
  }
}
