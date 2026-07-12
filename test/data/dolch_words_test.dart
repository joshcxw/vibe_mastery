import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_mastery/data/dolch_words.dart';

void main() {
  const expectedCounts = {
    DolchLevel.prePrimer: 40,
    DolchLevel.primer: 52,
    DolchLevel.firstGrade: 41,
    DolchLevel.secondGrade: 46,
    DolchLevel.thirdGrade: 41,
  };

  group('DolchWords', () {
    test('each level contains the expected number of words', () {
      for (final entry in expectedCounts.entries) {
        expect(
          DolchWords.forLevel(entry.key),
          hasLength(entry.value),
          reason: '${entry.key.displayName} has an unexpected word count.',
        );
      }
    });

    test('no level contains an empty value', () {
      for (final level in DolchLevel.values) {
        final hasEmptyWord = DolchWords.forLevel(level).any(
              (word) => word.trim().isEmpty,
        );

        expect(
          hasEmptyWord,
          isFalse,
          reason: '${level.displayName} contains an empty word.',
        );
      }
    });

    test('no level contains a duplicate word', () {
      for (final level in DolchLevel.values) {
        final words = DolchWords.forLevel(level);
        final uniqueWords = words.toSet();

        expect(
          uniqueWords,
          hasLength(words.length),
          reason: '${level.displayName} contains a duplicate word.',
        );
      }
    });

    test('exactly 220 required words exist in total', () {
      final totalWordCount = DolchLevel.values.fold<int>(
        0,
            (total, level) => total + DolchWords.forLevel(level).length,
      );

      expect(totalWordCount, 220);
    });
  });

  group('DolchLevel', () {
    test('stable level identifiers are unique', () {
      final ids = DolchLevel.values.map((level) => level.id).toSet();

      expect(ids, hasLength(DolchLevel.values.length));
    });
  });
}