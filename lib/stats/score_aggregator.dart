import '../data/dolch_words.dart';
import '../models/score_record.dart';

class ScoreSummary {
  const ScoreSummary({
    required this.completedRounds,
    required this.combinedScore,
    required this.wordMatchHistory,
    required this.wordMatchByLevel,
  });

  final int completedRounds;

  /// Null means there are no valid completed rounds.
  final int? combinedScore;

  final List<ScoreRecord> wordMatchHistory;
  final Map<DolchLevel, LevelScoreSummary> wordMatchByLevel;

  bool get isEmpty => completedRounds == 0;
}

class LevelScoreSummary {
  const LevelScoreSummary({
    required this.completedRounds,
    required this.averageScore,
    required this.bestScore,
  });

  final int completedRounds;
  final int averageScore;
  final int bestScore;
}

abstract final class ScoreAggregator {
  static ScoreSummary summarize(Iterable<ScoreRecord> records) {
    final validRecords = records
        .where((record) => record.isValid)
        .toList(growable: false);

    if (validRecords.isEmpty) {
      return const ScoreSummary(
        completedRounds: 0,
        combinedScore: null,
        wordMatchHistory: [],
        wordMatchByLevel: {},
      );
    }

    final totalScore = validRecords.fold<int>(
      0,
          (total, record) => total + record.score,
    );

    final combinedScore = (totalScore / validRecords.length).round();

    final wordMatchHistory = validRecords
        .where(
          (record) =>
      record.gameType == ScoreRecord.wordMatchGameType,
    )
        .toList()
      ..sort(
            (first, second) => second.playedAt.compareTo(first.playedAt),
      );

    final levelSummaries = <DolchLevel, LevelScoreSummary>{};

    for (final level in DolchLevel.values) {
      final levelRecords = wordMatchHistory
          .where((record) => record.levelId == level.id)
          .toList(growable: false);

      if (levelRecords.isEmpty) {
        continue;
      }

      final levelTotal = levelRecords.fold<int>(
        0,
            (total, record) => total + record.score,
      );

      final bestScore = levelRecords
          .map((record) => record.score)
          .reduce((first, second) => first > second ? first : second);

      levelSummaries[level] = LevelScoreSummary(
        completedRounds: levelRecords.length,
        averageScore: (levelTotal / levelRecords.length).round(),
        bestScore: bestScore,
      );
    }

    return ScoreSummary(
      completedRounds: validRecords.length,
      combinedScore: combinedScore.clamp(0, 100),
      wordMatchHistory: List.unmodifiable(wordMatchHistory),
      wordMatchByLevel: Map.unmodifiable(levelSummaries),
    );
  }
}