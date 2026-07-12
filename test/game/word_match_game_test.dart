import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_mastery/game/word_match_game.dart';
import 'package:vibe_mastery/models/game_card.dart';
import 'package:vibe_mastery/game/round_timer.dart';

void main() {
  const availableWords = [
    'a',
    'and',
    'away',
    'big',
    'blue',
    'can',
    'come',
    'down',
  ];

  late WordMatchGame game;

  setUp(() {
    game = WordMatchGame(random: Random(1));
    game.startRound(availableWords);
  });

  group('round creation', () {
    test('creates twelve hidden cards from six unique words', () {
      expect(game.cards, hasLength(12));

      final wordCounts = <String, int>{};

      for (final card in game.cards) {
        wordCounts.update(
          card.word,
              (count) => count + 1,
          ifAbsent: () => 1,
        );

        expect(card.state, GameCardState.hidden);
      }

      expect(wordCounts, hasLength(6));
      expect(wordCounts.values, everyElement(2));
    });

    test('gives every card a unique identifier', () {
      final cardIds = game.cards.map((card) => card.id).toSet();

      expect(cardIds, hasLength(12));
    });

    test('starts with all counters cleared', () {
      expect(game.flips, 0);
      expect(game.attemptedPairs, 0);
      expect(game.matches, 0);
      expect(game.mismatches, 0);
      expect(game.isComplete, isFalse);
      expect(game.isMismatchPending, isFalse);
    });

    test('rejects a list with fewer than six unique words', () {
      expect(
            () => game.startRound(['a', 'a', 'and', 'away', 'big', 'blue']),
        throwsArgumentError,
      );
    });
  });

  group('card selection', () {
    test('reveals the first selected card', () {
      final card = game.cards.first;

      final result = game.tapCard(card.id);

      expect(result, CardTapResult.firstCardRevealed);
      expect(_cardById(game, card.id).state, GameCardState.revealed);
      expect(game.flips, 1);
      expect(game.attemptedPairs, 0);
    });

    test('ignores a second tap on the same revealed card', () {
      final card = game.cards.first;

      game.tapCard(card.id);
      final result = game.tapCard(card.id);

      expect(result, CardTapResult.ignored);
      expect(game.flips, 1);
      expect(game.attemptedPairs, 0);
    });

    test('permanently matches two cards with the same word', () {
      final pair = _findMatchingPair(game);

      game.tapCard(pair.$1.id);
      final result = game.tapCard(pair.$2.id);

      expect(result, CardTapResult.match);
      expect(
        _cardById(game, pair.$1.id).state,
        GameCardState.matched,
      );
      expect(
        _cardById(game, pair.$2.id).state,
        GameCardState.matched,
      );

      expect(game.flips, 2);
      expect(game.attemptedPairs, 1);
      expect(game.matches, 1);
      expect(game.mismatches, 0);
    });

    test('ignores taps on an already matched card', () {
      final pair = _findMatchingPair(game);

      game.tapCard(pair.$1.id);
      game.tapCard(pair.$2.id);

      final result = game.tapCard(pair.$1.id);

      expect(result, CardTapResult.ignored);
      expect(game.flips, 2);
      expect(game.attemptedPairs, 1);
    });
  });

  group('mismatch handling', () {
    test('keeps nonmatching cards revealed until mismatch is hidden', () {
      final cards = _findNonmatchingCards(game);

      game.tapCard(cards.$1.id);
      final result = game.tapCard(cards.$2.id);

      expect(result, CardTapResult.mismatch);
      expect(game.isMismatchPending, isTrue);

      expect(
        _cardById(game, cards.$1.id).state,
        GameCardState.revealed,
      );
      expect(
        _cardById(game, cards.$2.id).state,
        GameCardState.revealed,
      );

      expect(game.flips, 2);
      expect(game.attemptedPairs, 1);
      expect(game.matches, 0);
      expect(game.mismatches, 1);
    });

    test('ignores a third card while a mismatch is pending', () {
      final cards = _findNonmatchingCards(game);

      game.tapCard(cards.$1.id);
      game.tapCard(cards.$2.id);

      final thirdCard = game.cards.firstWhere(
            (card) =>
        card.id != cards.$1.id &&
            card.id != cards.$2.id,
      );

      final result = game.tapCard(thirdCard.id);

      expect(result, CardTapResult.ignored);
      expect(_cardById(game, thirdCard.id).state, GameCardState.hidden);
      expect(game.flips, 2);
      expect(game.attemptedPairs, 1);
    });

    test('hides both cards and unlocks input after a mismatch', () {
      final cards = _findNonmatchingCards(game);

      game.tapCard(cards.$1.id);
      game.tapCard(cards.$2.id);

      final didHide = game.hideMismatch();

      expect(didHide, isTrue);
      expect(game.isMismatchPending, isFalse);

      expect(
        _cardById(game, cards.$1.id).state,
        GameCardState.hidden,
      );
      expect(
        _cardById(game, cards.$2.id).state,
        GameCardState.hidden,
      );

      final nextCard = game.cards.first;
      expect(
        game.tapCard(nextCard.id),
        CardTapResult.firstCardRevealed,
      );
    });

    test('does nothing when there is no pending mismatch', () {
      expect(game.hideMismatch(), isFalse);
    });
  });

  group('round completion', () {
    test('becomes complete exactly after all six pairs are matched', () {
      final cardsByWord = <String, List<GameCard>>{};

      for (final card in game.cards) {
        cardsByWord.putIfAbsent(card.word, () => []).add(card);
      }

      final pairs = cardsByWord.values.toList();

      for (var index = 0; index < pairs.length; index++) {
        final pair = pairs[index];

        game.tapCard(pair[0].id);
        final result = game.tapCard(pair[1].id);

        if (index < pairs.length - 1) {
          expect(result, CardTapResult.match);
          expect(game.isComplete, isFalse);
        } else {
          expect(result, CardTapResult.roundComplete);
          expect(game.isComplete, isTrue);
        }
      }

      expect(game.matches, 6);
      expect(game.mismatches, 0);
      expect(game.attemptedPairs, 6);
      expect(game.flips, 12);
      expect(
        game.cards.every(
              (card) => card.state == GameCardState.matched,
        ),
        isTrue,
      );
    });
  });

  group('reset', () {
    test('clears old cards, selections, and counters', () {
      final mismatch = _findNonmatchingCards(game);

      game.tapCard(mismatch.$1.id);
      game.tapCard(mismatch.$2.id);

      final oldCardIds = game.cards.map((card) => card.id).toSet();

      game.resetRound(availableWords);

      final newCardIds = game.cards.map((card) => card.id).toSet();

      expect(game.cards, hasLength(12));
      expect(game.cards.every(
            (card) => card.state == GameCardState.hidden,
      ), isTrue);

      expect(game.flips, 0);
      expect(game.attemptedPairs, 0);
      expect(game.matches, 0);
      expect(game.mismatches, 0);
      expect(game.isMismatchPending, isFalse);
      expect(game.isComplete, isFalse);

      expect(oldCardIds.intersection(newCardIds), isEmpty);
    });
  });
}

GameCard _cardById(WordMatchGame game, String id) {
  return game.cards.firstWhere((card) => card.id == id);
}

(GameCard, GameCard) _findMatchingPair(WordMatchGame game) {
  for (final firstCard in game.cards) {
    for (final secondCard in game.cards) {
      if (firstCard.id != secondCard.id &&
          firstCard.word == secondCard.word) {
        return (firstCard, secondCard);
      }
    }
  }

  throw StateError('No matching pair found.');
}

(GameCard, GameCard) _findNonmatchingCards(WordMatchGame game) {
  for (final firstCard in game.cards) {
    for (final secondCard in game.cards) {
      if (firstCard.id != secondCard.id &&
          firstCard.word != secondCard.word) {
        return (firstCard, secondCard);
      }
    }
  }

  throw StateError('No nonmatching cards found.');
}