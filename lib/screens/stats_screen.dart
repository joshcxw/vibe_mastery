import 'package:flutter/material.dart';

import '../data/dolch_words.dart';
import '../models/score_record.dart';
import '../stats/score_aggregator.dart';
import '../storage/score_storage.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ScoreStorage _storage = ScoreStorage();

  late Future<ScoreSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<ScoreSummary> _loadSummary() async {
    final records = await _storage.loadRecords();
    return ScoreAggregator.summarize(records);
  }

  void _returnHome() {
    Navigator.popUntil(
      context,
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
      ),
      body: SafeArea(
        child: FutureBuilder<ScoreSummary>(
          future: _summaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final summary = snapshot.data ??
                ScoreAggregator.summarize(const []);

            if (summary.isEmpty) {
              return _EmptyStats(
                onHome: _returnHome,
              );
            }

            return _StatsContent(
              summary: summary,
              onHome: _returnHome,
            );
          },
        ),
      ),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats({
    required this.onHome,
  });

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                size: 96,
              ),
              const SizedBox(height: 20),
              Text(
                'No Scores Yet',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Icon(
                Icons.play_circle_fill_rounded,
                size: 54,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onHome,
                icon: const Icon(
                  Icons.home_rounded,
                  size: 30,
                ),
                label: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({
    required this.summary,
    required this.onHome,
  });

  final ScoreSummary summary;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _OverallSummary(summary: summary),
        const SizedBox(height: 24),
        Text(
          'By Level',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        for (final level in DolchLevel.values)
          if (summary.wordMatchByLevel[level] case final levelSummary?)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LevelSummaryTile(
                level: level,
                summary: levelSummary,
              ),
            ),
        const SizedBox(height: 14),
        Text(
          'Word Match History',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        for (final record in summary.wordMatchHistory)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _HistoryTile(record: record),
          ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onHome,
          icon: const Icon(
            Icons.home_rounded,
            size: 30,
          ),
          label: const Text('Home'),
        ),
      ],
    );
  }
}

class _OverallSummary extends StatelessWidget {
  const _OverallSummary({
    required this.summary,
  });

  final ScoreSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _LargeStat(
              icon: Icons.stars_rounded,
              value: '${summary.combinedScore ?? '—'}',
              label: 'Combined',
            ),
          ),
          Container(
            width: 1,
            height: 70,
            color: colors.onPrimaryContainer.withAlpha(70),
          ),
          Expanded(
            child: _LargeStat(
              icon: Icons.sports_esports_rounded,
              value: '${summary.completedRounds}',
              label: 'Rounds',
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeStat extends StatelessWidget {
  const _LargeStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 34),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _LevelSummaryTile extends StatelessWidget {
  const _LevelSummaryTile({
    required this.level,
    required this.summary,
  });

  final DolchLevel level;
  final LevelScoreSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.school_rounded,
              size: 32,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                level.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            _SmallValue(
              value: '${summary.completedRounds}',
              label: 'Rounds',
            ),
            const SizedBox(width: 16),
            _SmallValue(
              value: '${summary.averageScore}',
              label: 'Average',
            ),
            const SizedBox(width: 16),
            _SmallValue(
              value: '${summary.bestScore}',
              label: 'Best',
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallValue extends StatelessWidget {
  const _SmallValue({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.record,
  });

  final ScoreRecord record;

  @override
  Widget build(BuildContext context) {
    final levelName = _levelDisplayName(record.levelId);
    final seconds = Duration(
      milliseconds: record.elapsedMilliseconds,
    ).inSeconds;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            '${record.score}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(levelName),
        subtitle: Text(
          '${record.matches} matches • '
              '${record.mismatches} misses • '
              '${seconds}s',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  String _levelDisplayName(String levelId) {
    for (final level in DolchLevel.values) {
      if (level.id == levelId) {
        return level.displayName;
      }
    }

    return 'Unknown Level';
  }
}