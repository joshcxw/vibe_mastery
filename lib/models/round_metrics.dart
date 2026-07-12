class RoundMetrics
{
  const RoundMetrics({
    required this.numberOfPairs,
    required this.totalFlips,
    required this.pairAttempts,
    required this.mismatches,
    required this.matches,
    required this.elapsedTime,
  });

  final int numberOfPairs;
  final int totalFlips;
  final int pairAttempts;
  final int mismatches;
  final int matches;
  final Duration elapsedTime;
}