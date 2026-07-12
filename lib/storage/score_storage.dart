import 'package:shared_preferences/shared_preferences.dart';

import '../models/score_record.dart';

class ScoreStorage {
  ScoreStorage({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _recordsKey = 'score_records_v1';

  final SharedPreferencesAsync _preferences;

  Future<List<ScoreRecord>> loadRecords() async {
    try {
      final encodedRecords =
          await _preferences.getStringList(_recordsKey) ?? const [];

      return encodedRecords
          .map(ScoreRecord.decode)
          .whereType<ScoreRecord>()
          .toList(growable: false);
    } on TypeError {
      return const [];
    } on FormatException {
      return const [];
    }
  }

  /// Adds [record] only when its unique ID has not already been stored.
  ///
  /// Returns true if a new record was written.
  Future<bool> saveIfAbsent(ScoreRecord record) async {
    if (!record.isValid) {
      return false;
    }

    final existingRecords = await loadRecords();

    final alreadySaved = existingRecords.any(
          (existing) => existing.id == record.id,
    );

    if (alreadySaved) {
      return false;
    }

    final updatedRecords = [
      ...existingRecords,
      record,
    ];

    await _preferences.setStringList(
      _recordsKey,
      updatedRecords.map((item) => item.encode()).toList(),
    );

    return true;
  }
}