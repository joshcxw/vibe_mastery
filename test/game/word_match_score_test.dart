import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_mastery/game/word_match_score.dart';
import 'package:vibe_mastery/models/round_metrics.dart';

void main() {
  RoundMetrics metrics({
    required int pairs,
    required int attempts,
    int flips = 0,
    int mismatches = 0,
    int matches = 0,
    Duration elapsed = Duration.zero,
  }) {
    return RoundMetrics(
      numberOfPairs: pairs,
      totalFlips: flips,
      pairAttempts: attempts,
      mismatches: mismatches,
      matches: matches,
      elapsedTime: elapsed,
    );
  }

  group('WordMatchScore.calculate', () {
    test('returns 100 for a perfect six-pair round', () {
      final score = WordMatchScore.calculate(
        metrics(
          pairs: 6,
          attempts: 6,
          flips: 12,
          matches: 6,
        ),
      );

      expect(score, 100);
    });

    test('returns 50 when six pairs require twelve attempts', () {
      final score = WordMatchScore.calculate(
        metrics(
          pairs: 6,
          attempts: 12,
          flips: 24,
          matches: 6,
          mismatches: 6,
        ),
      );

      expect(score, 50);
    });

    test('rounds the result to the nearest whole number', () {
      final score = WordMatchScore.calculate(
        metrics(
          pairs: 6,
          attempts: 8,
        ),
      );

      expect(score, 75);
    });

    test('rounds a repeating decimal correctly', () {
      final score = WordMatchScore.calculate(
        metrics(
          pairs: 6,
          attempts: 9,
        ),
      );

      expect(score, 67);
    });

    test('clamps an impossible above-maximum result to 100', () {
      final score = WordMatchScore.calculate(
        metrics(
          pairs: 6,
          attempts: 1,
        ),
      );

      expect(score, 100);
    });

    test('returns zero when pair attempts are zero', () {
      final score = WordMatchScore.calculate(
        metrics(
          pairs: 6,
          attempts: 0,
        ),
      );

      expect(score, 0);
    });

    test('returns zero when number of pairs is zero', () {
      final score = WordMatchScore.calculate(
        metrics(
          pairs: 0,
          attempts: 6,
        ),
      );

      expect(score, 0);
    });

    test('returns zero for negative attempts', () {
      final score = WordMatchScore.calculate(
        metrics(
          pairs: 6,
          attempts: -1,
        ),
      );

      expect(score, 0);
    });

    test('elapsed time does not change the selected score model', () {
      final fastScore = WordMatchScore.calculate(
        metrics(
          pairs: 6,
          attempts: 8,
          elapsed: const Duration(seconds: 10),
        ),
      );

      final slowScore = WordMatchScore.calculate(
        metrics(
          pairs: 6,
          attempts: 8,
          elapsed: const Duration(minutes: 5),
        ),
      );

      expect(fastScore, slowScore);
      expect(fastScore, 75);
    });
  });
}