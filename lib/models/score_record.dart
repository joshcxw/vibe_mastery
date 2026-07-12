import 'dart:convert';

import 'round_result.dart';

class ScoreRecord {
  const ScoreRecord({
    required this.id,
    required this.gameType,
    required this.levelId,
    required this.score,
    required this.playedAt,
    required this.matches,
    required this.mismatches,
    required this.pairAttempts,
    required this.totalFlips,
    required this.elapsedMilliseconds,
  });

  static const String wordMatchGameType = 'word_match';

  final String id;
  final String gameType;
  final String levelId;
  final int score;
  final DateTime playedAt;

  final int matches;
  final int mismatches;
  final int pairAttempts;
  final int totalFlips;
  final int elapsedMilliseconds;

  bool get isValid {
    return id.trim().isNotEmpty &&
        gameType.trim().isNotEmpty &&
        levelId.trim().isNotEmpty &&
        score >= 0 &&
        score <= 100 &&
        matches >= 0 &&
        mismatches >= 0 &&
        pairAttempts >= 0 &&
        totalFlips >= 0 &&
        elapsedMilliseconds >= 0;
  }

  factory ScoreRecord.fromRoundResult({
    required String id,
    required String levelId,
    required RoundResult result,
    required DateTime playedAt,
  }) {
    return ScoreRecord(
      id: id,
      gameType: wordMatchGameType,
      levelId: levelId,
      score: result.score,
      playedAt: playedAt,
      matches: result.metrics.matches,
      mismatches: result.metrics.mismatches,
      pairAttempts: result.metrics.pairAttempts,
      totalFlips: result.metrics.totalFlips,
      elapsedMilliseconds: result.metrics.elapsedTime.inMilliseconds,
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'gameType': gameType,
      'levelId': levelId,
      'score': score,
      'playedAt': playedAt.toIso8601String(),
      'matches': matches,
      'mismatches': mismatches,
      'pairAttempts': pairAttempts,
      'totalFlips': totalFlips,
      'elapsedMilliseconds': elapsedMilliseconds,
    };
  }

  String encode() {
    return jsonEncode(toJson());
  }

  static ScoreRecord? decode(String encodedRecord) {
    try {
      final decoded = jsonDecode(encodedRecord);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final playedAtValue = decoded['playedAt'];

      if (playedAtValue is! String) {
        return null;
      }

      final playedAt = DateTime.tryParse(playedAtValue);

      if (playedAt == null) {
        return null;
      }

      final record = ScoreRecord(
        id: decoded['id'] as String,
        gameType: decoded['gameType'] as String,
        levelId: decoded['levelId'] as String,
        score: decoded['score'] as int,
        playedAt: playedAt,
        matches: decoded['matches'] as int,
        mismatches: decoded['mismatches'] as int,
        pairAttempts: decoded['pairAttempts'] as int,
        totalFlips: decoded['totalFlips'] as int,
        elapsedMilliseconds: decoded['elapsedMilliseconds'] as int,
      );

      return record.isValid ? record : null;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}