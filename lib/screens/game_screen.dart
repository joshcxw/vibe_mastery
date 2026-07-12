import 'dart:async';

import 'package:flutter/material.dart';

import '../data/dolch_words.dart';
import '../game/word_match_game.dart';
import '../models/game_card.dart';
import '../widgets/word_card.dart';
import 'results_screen.dart';
import '../models/score_record.dart';
import '../storage/score_storage.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.selectedLevel,
    super.key,
  });

  final DolchLevel selectedLevel;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const Duration _mismatchDelay = Duration(milliseconds: 900);
  static const Duration _completionDelay = Duration(milliseconds: 500);
  final ScoreStorage _scoreStorage = ScoreStorage();

  bool _isFinalizingRound = false;
  String? _completedRecordId;

  late final WordMatchGame _game;

  Timer? _delayedActionTimer;

  int _roundVersion = 0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _game = WordMatchGame();
    _startRound();
  }

  void _startRound() {
    _delayedActionTimer?.cancel();
    _roundVersion++;

    _isFinalizingRound = false;
    _completedRecordId = null;

    _game.startRound(
      DolchWords.forLevel(widget.selectedLevel),
    );
  }

  void _handleCardTap(GameCard card) {
    if (_isNavigating || _game.isMismatchPending || _game.isComplete) {
      return;
    }

    final result = _game.tapCard(card.id);

    if (result == CardTapResult.ignored) {
      return;
    }

    setState(() {});

    if (result == CardTapResult.mismatch) {
      _scheduleMismatchHide();
    } else if (result == CardTapResult.roundComplete) {
      _scheduleResultsNavigation();
    }
  }

  void _scheduleMismatchHide() {
    _delayedActionTimer?.cancel();

    final scheduledRoundVersion = _roundVersion;

    _delayedActionTimer = Timer(_mismatchDelay, () {
      if (!mounted ||
          scheduledRoundVersion != _roundVersion ||
          !_game.isMismatchPending) {
        return;
      }

      setState(() {
        _game.hideMismatch();
      });
    });
  }

  void _scheduleResultsNavigation() {
    _delayedActionTimer?.cancel();

    final scheduledRoundVersion = _roundVersion;

    _delayedActionTimer = Timer(_completionDelay, () {
      _finishCompletedRound(scheduledRoundVersion);
    });
  }

  Future<void> _finishCompletedRound(
      int scheduledRoundVersion,
      ) async {
    if (!mounted ||
        scheduledRoundVersion != _roundVersion ||
        _isNavigating ||
        _isFinalizingRound ||
        !_game.isComplete) {
      return;
    }

    final result = _game.finalResult;

    if (result == null) {
      return;
    }

    _isFinalizingRound = true;

    final playedAt = DateTime.now();

    _completedRecordId ??=
    '${playedAt.microsecondsSinceEpoch}-${widget.selectedLevel.id}';

    final record = ScoreRecord.fromRoundResult(
      id: _completedRecordId!,
      levelId: widget.selectedLevel.id,
      result: result,
      playedAt: playedAt,
    );

    try {
      await _scoreStorage.saveIfAbsent(record);
    } catch (_) {
      if (!mounted || scheduledRoundVersion != _roundVersion) {
        return;
      }

      _isFinalizingRound = false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The score could not be saved.'),
        ),
      );

      return;
    }

    if (!mounted ||
        scheduledRoundVersion != _roundVersion ||
        _isNavigating) {
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ResultsScreen(
          selectedLevel: widget.selectedLevel,
          result: result,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _delayedActionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedLevel.displayName),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: Column(
            children: [
              _RoundStatus(
                matches: _game.matches,
                totalPairs: WordMatchGame.pairCount,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _buildResponsiveGrid(constraints);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(BoxConstraints constraints) {
    final columnCount = constraints.maxWidth >= 600 ? 4 : 3;
    final rowCount = (WordMatchGame.cardCount / columnCount).ceil();

    const spacing = 10.0;

    final totalHorizontalSpacing = spacing * (columnCount - 1);
    final totalVerticalSpacing = spacing * (rowCount - 1);

    final cardWidth =
        (constraints.maxWidth - totalHorizontalSpacing) / columnCount;

    final cardHeight =
        (constraints.maxHeight - totalVerticalSpacing) / rowCount;

    final safeCardHeight = cardHeight <= 0 ? cardWidth : cardHeight;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _game.cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: cardWidth / safeCardHeight,
      ),
      itemBuilder: (context, index) {
        final card = _game.cards[index];

        return WordCard(
          key: ValueKey(card.id),
          card: card,
          enabled: !_isNavigating && !_game.isMismatchPending,
          onTap: () => _handleCardTap(card),
        );
      },
    );
  }
}

class _RoundStatus extends StatelessWidget {
  const _RoundStatus({
    required this.matches,
    required this.totalPairs,
  });

  final int matches;
  final int totalPairs;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$matches of $totalPairs pairs matched',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            '$matches / $totalPairs',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}