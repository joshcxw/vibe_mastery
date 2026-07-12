import 'package:flutter/material.dart';

import '../data/dolch_words.dart';
import 'results_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.selectedLevel,
    super.key,
  });

  final DolchLevel selectedLevel;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isNavigating = false;

  void _openPlaceholderResults() {
    if (_isNavigating) {
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ResultsScreen(
          selectedLevel: widget.selectedLevel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordCount = DolchWords.forLevel(widget.selectedLevel).length;

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
                    widget.selectedLevel.displayName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$wordCount available words',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The matching grid will be added later.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 40),
                  FilledButton.icon(
                    onPressed:
                    _isNavigating ? null : _openPlaceholderResults,
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