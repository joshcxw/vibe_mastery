import 'package:flutter/material.dart';

import 'results_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  void _openPlaceholderResults(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const ResultsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.grid_view_rounded,
                    size: 96,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Game Screen',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The card grid will be added in a later checkpoint.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 40),
                  FilledButton.icon(
                    onPressed: () => _openPlaceholderResults(context),
                    icon: const Icon(Icons.emoji_events_rounded),
                    label: const Text('Test Results Screen'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}