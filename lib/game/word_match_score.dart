import '../models/round_metrics.dart';

abstract final class WordMatchScore {
  static const int minimumScore = 0;
  static const int maximumScore = 100;

  /// Calculates a normalized Word Match score from 0 to 100.
  ///
  /// A perfect round uses one pair attempt per available pair.
  static int calculate(RoundMetrics metrics) {
    if (metrics.numberOfPairs <= 0 || metrics.pairAttempts <= 0) {
      return minimumScore;
    }

    final rawScore =
        maximumScore * metrics.numberOfPairs / metrics.pairAttempts;

    return rawScore
        .round()
        .clamp(minimumScore, maximumScore);
  }
}