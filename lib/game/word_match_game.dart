import 'dart:math';

import '../models/game_card.dart';
import '../models/round_metrics.dart';
import '../models/round_result.dart';
import 'round_timer.dart';
import 'word_match_score.dart';

enum CardTapResult {
  firstCardRevealed,
  match,
  mismatch,
  roundComplete,
  ignored,
}

class WordMatchGame {
  WordMatchGame({
    Random? random,
    RoundTimer? timer,
  })  : _random = random ?? Random(),
        _timer = timer ?? RoundTimer();

  static const int pairCount = 6;
  static const int cardCount = pairCount * 2;

  final Random _random;
  final RoundTimer _timer;
  RoundResult? _finalResult;

  final List<GameCard> _cards = [];

  String? _firstCardId;
  String? _secondCardId;
  bool _isMismatchPending = false;
  int _roundNumber = 0;

  int flips = 0;
  int attemptedPairs = 0;
  int matches = 0;
  int mismatches = 0;

  List<GameCard> get cards => List.unmodifiable(_cards);

  RoundResult? get finalResult => _finalResult;

  Duration get elapsedTime => _timer.elapsed;

  bool get isMismatchPending => _isMismatchPending;

  bool get isComplete => matches == pairCount;

  /// Starts a completely new six-pair round.
  ///
  /// At least six unique words must be available.
  void startRound(List<String> availableWords) {
    final uniqueWords = availableWords.toSet().toList();

    if (uniqueWords.length < pairCount) {
      throw ArgumentError(
        'A Word Match round requires at least $pairCount unique words.',
      );
    }

    _clearRoundState();
    _timer.start();
    _roundNumber++;

    uniqueWords.shuffle(_random);
    final chosenWords = uniqueWords.take(pairCount);

    var cardNumber = 0;

    for (final word in chosenWords) {
      _cards.add(
        GameCard(
          id: 'round-$_roundNumber-card-${cardNumber++}',
          word: word,
        ),
      );

      _cards.add(
        GameCard(
          id: 'round-$_roundNumber-card-${cardNumber++}',
          word: word,
        ),
      );
    }

    _cards.shuffle(_random);
  }

  /// Starts another round and clears all state from the previous round.
  void resetRound(List<String> availableWords) {
    startRound(availableWords);
  }

  CardTapResult tapCard(String cardId) {
    if (_isMismatchPending || isComplete) {
      return CardTapResult.ignored;
    }

    final cardIndex = _findCardIndex(cardId);

    if (cardIndex == -1) {
      return CardTapResult.ignored;
    }

    final selectedCard = _cards[cardIndex];

    if (selectedCard.state == GameCardState.matched) {
      return CardTapResult.ignored;
    }

    if (cardId == _firstCardId) {
      return CardTapResult.ignored;
    }

    if (selectedCard.state != GameCardState.hidden) {
      return CardTapResult.ignored;
    }

    _setCardState(cardIndex, GameCardState.revealed);
    flips++;

    if (_firstCardId == null) {
      _firstCardId = cardId;
      return CardTapResult.firstCardRevealed;
    }

    _secondCardId = cardId;
    attemptedPairs++;

    final firstCardIndex = _findCardIndex(_firstCardId!);
    final firstCard = _cards[firstCardIndex];
    final secondCard = _cards[cardIndex];

    if (firstCard.word == secondCard.word) {
      _setCardState(firstCardIndex, GameCardState.matched);
      _setCardState(cardIndex, GameCardState.matched);

      matches++;
      _clearSelection();

      if (isComplete) {
        _finalizeResultOnce();
        return CardTapResult.roundComplete;
      }

      return CardTapResult.match;
    }

    mismatches++;
    _isMismatchPending = true;

    return CardTapResult.mismatch;
  }

  /// Hides the two nonmatching cards after the UI's brief display delay.
  ///
  /// Returns true when a pending mismatch was resolved.
  bool hideMismatch() {
    if (!_isMismatchPending ||
        _firstCardId == null ||
        _secondCardId == null) {
      return false;
    }

    final firstCardIndex = _findCardIndex(_firstCardId!);
    final secondCardIndex = _findCardIndex(_secondCardId!);

    if (firstCardIndex != -1) {
      _setCardState(firstCardIndex, GameCardState.hidden);
    }

    if (secondCardIndex != -1) {
      _setCardState(secondCardIndex, GameCardState.hidden);
    }

    _clearSelection();
    _isMismatchPending = false;

    return true;
  }

  int _findCardIndex(String cardId) {
    return _cards.indexWhere((card) => card.id == cardId);
  }

  void _setCardState(int index, GameCardState state) {
    _cards[index] = _cards[index].withState(state);
  }

  void _clearSelection() {
    _firstCardId = null;
    _secondCardId = null;
  }

  void _clearRoundState() {
    _timer.reset();
    _finalResult = null;

    _cards.clear();
    _clearSelection();

    _isMismatchPending = false;

    flips = 0;
    attemptedPairs = 0;
    matches = 0;
    mismatches = 0;
  }

  void _finalizeResultOnce() {
    if (_finalResult != null) {
      return;
    }

    _timer.stop();

    final metrics = RoundMetrics(
      numberOfPairs: pairCount,
      totalFlips: flips,
      pairAttempts: attemptedPairs,
      mismatches: mismatches,
      matches: matches,
      elapsedTime: _timer.elapsed,
    );

    _finalResult = RoundResult(
      score: WordMatchScore.calculate(metrics),
      metrics: metrics,
    );
  }

}