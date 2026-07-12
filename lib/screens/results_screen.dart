import 'package:flutter/material.dart';

import '../data/dolch_words.dart';
import '../models/round_result.dart';
import 'game_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    required this.selectedLevel,
    required this.result,
    super.key,
  });

  final DolchLevel selectedLevel;
  final RoundResult result;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isNavigating = false;

  void _playAgain() {
    if (_isNavigating) {
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => GameScreen(
          selectedLevel: widget.selectedLevel,
        ),
      ),
    );
  }

  void _returnHome() {
    if (_isNavigating) {
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    Navigator.popUntil(
      context,
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = widget.result.metrics;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.selectedLevel.displayName),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _CelebrationHeader(),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.result.score}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                            fontSize: 80,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        Text(
                          'SCORE',
                          style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _MetricsSummary(
                          matches: metrics.matches,
                          mismatches: metrics.mismatches,
                          elapsedTime: metrics.elapsedTime,
                        ),
                        const SizedBox(height: 36),
                        FilledButton.icon(
                          onPressed: _isNavigating ? null : _playAgain,
                          icon: const Icon(
                            Icons.replay_rounded,
                            size: 32,
                          ),
                          label: const Text('Play Again'),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _isNavigating ? null : _returnHome,
                          icon: const Icon(
                            Icons.home_rounded,
                            size: 30,
                          ),
                          label: const Text('Home'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(
                              double.infinity,
                              64,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
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

class _CelebrationHeader extends StatelessWidget {
  const _CelebrationHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Round complete',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 42,
            color: colors.tertiary,
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.emoji_events_rounded,
            size: 92,
            color: colors.primary,
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.auto_awesome_rounded,
            size: 42,
            color: colors.tertiary,
          ),
        ],
      ),
    );
  }
}

class _MetricsSummary extends StatelessWidget {
  const _MetricsSummary({
    required this.matches,
    required this.mismatches,
    required this.elapsedTime,
  });

  final int matches;
  final int mismatches;
  final Duration elapsedTime;

  @override
  Widget build(BuildContext context) {
    final elapsedText = _formatDuration(elapsedTime);

    return Row(
      children: [
        Expanded(
          child: _MetricItem(
            icon: Icons.check_circle_rounded,
            value: '$matches',
            label: 'Matches',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricItem(
            icon: Icons.refresh_rounded,
            value: '$mismatches',
            label: 'Misses',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricItem(
            icon: Icons.timer_rounded,
            value: elapsedText,
            label: 'Time',
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    if (minutes == 0) {
      return '${seconds}s';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.outlineVariant,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: colors.primary,
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}