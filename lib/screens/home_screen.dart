import 'package:flutter/material.dart';

import '../data/dolch_words.dart';
import 'game_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isNavigating = false;

  Future<void> _openGame(DolchLevel level) async {
    if (_isNavigating) {
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => GameScreen(selectedLevel: level),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isNavigating = false;
    });
  }

  Future<void> _openStats() async {
    if (_isNavigating) {
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const StatsScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Match'),
        actions: [
          IconButton(
            tooltip: 'Open stats',
            onPressed: _isNavigating ? null : _openStats,
            icon: const Icon(
              Icons.bar_chart_rounded,
              size: 30,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.style_rounded,
                          size: 76,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Word Match',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 28),
                        for (final level in DolchLevel.values) ...[
                          _LevelButton(
                            level: level,
                            enabled: !_isNavigating,
                            onPressed: () => _openGame(level),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _isNavigating ? null : _openStats,
                          icon: const Icon(
                            Icons.bar_chart_rounded,
                            size: 28,
                          ),
                          label: const Text('Stats'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 60),
                            textStyle: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({
    required this.level,
    required this.enabled,
    required this.onPressed,
  });

  final DolchLevel level;
  final bool enabled;
  final VoidCallback onPressed;

  int get _levelNumber => DolchLevel.values.indexOf(level) + 1;

  IconData get _icon {
    return switch (level) {
      DolchLevel.prePrimer => Icons.star_rounded,
      DolchLevel.primer => Icons.auto_awesome_rounded,
      DolchLevel.firstGrade => Icons.school_rounded,
      DolchLevel.secondGrade => Icons.menu_book_rounded,
      DolchLevel.thirdGrade => Icons.workspace_premium_rounded,
    };
  }

  Color _backgroundColor(ColorScheme colors) {
    return switch (level) {
      DolchLevel.prePrimer => colors.primaryContainer,
      DolchLevel.primer => colors.secondaryContainer,
      DolchLevel.firstGrade => colors.tertiaryContainer,
      DolchLevel.secondGrade => colors.surfaceContainerHighest,
      DolchLevel.thirdGrade => colors.inversePrimary,
    };
  }

  Color _foregroundColor(ColorScheme colors) {
    return switch (level) {
      DolchLevel.prePrimer => colors.onPrimaryContainer,
      DolchLevel.primer => colors.onSecondaryContainer,
      DolchLevel.firstGrade => colors.onTertiaryContainer,
      DolchLevel.secondGrade => colors.onSurface,
      DolchLevel.thirdGrade => colors.onPrimaryContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Play ${level.displayName}',
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 74),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          backgroundColor: _backgroundColor(colors),
          foregroundColor: _foregroundColor(colors),
          disabledBackgroundColor: _backgroundColor(colors).withAlpha(120),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: colors.surface.withAlpha(210),
              foregroundColor: colors.onSurface,
              child: Text(
                '$_levelNumber',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Icon(
              _icon,
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                level.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(
              Icons.play_arrow_rounded,
              size: 34,
            ),
          ],
        ),
      ),
    );
  }
}