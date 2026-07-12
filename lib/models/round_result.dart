import 'round_metrics.dart';

class RoundResult {
  const RoundResult({
    required this.score,
    required this.metrics,
  });

  final int score;
  final RoundMetrics metrics;
}
