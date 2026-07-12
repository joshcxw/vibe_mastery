import 'package:flutter/material.dart';

import '../models/game_card.dart';

class WordCard extends StatelessWidget {
  const WordCard({
    required this.card,
    required this.onTap,
    required this.enabled,
    super.key,
  });

  final GameCard card;
  final VoidCallback onTap;
  final bool enabled;

  bool get _isHidden => card.state == GameCardState.hidden;

  bool get _isMatched => card.state == GameCardState.matched;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canTap = enabled && _isHidden;

    final backgroundColor = switch (card.state) {
      GameCardState.hidden => colors.primaryContainer,
      GameCardState.revealed => colors.surface,
      GameCardState.matched => colors.tertiaryContainer,
    };

    final foregroundColor = switch (card.state) {
      GameCardState.hidden => colors.onPrimaryContainer,
      GameCardState.revealed => colors.onSurface,
      GameCardState.matched => colors.onTertiaryContainer,
    };

    return Semantics(
      button: canTap,
      enabled: canTap,
      label: _isHidden ? 'Hidden word card' : card.word,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        elevation: _isHidden ? 3 : 1,
        child: InkWell(
          onTap: canTap ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.88,
                    end: 1,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _isHidden
                ? _HiddenCardFace(
              key: const ValueKey('hidden'),
              foregroundColor: foregroundColor,
            )
                : _WordCardFace(
              key: ValueKey(card.state),
              word: card.word,
              matched: _isMatched,
              foregroundColor: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _HiddenCardFace extends StatelessWidget {
  const _HiddenCardFace({
    required this.foregroundColor,
    super.key,
  });

  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.auto_awesome_rounded,
        size: 40,
        color: foregroundColor,
      ),
    );
  }
}

class _WordCardFace extends StatelessWidget {
  const _WordCardFace({
    required this.word,
    required this.matched,
    required this.foregroundColor,
    super.key,
  });

  final String word;
  final bool matched;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                word,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
        if (matched)
          Positioned(
            top: 6,
            right: 6,
            child: Icon(
              Icons.check_circle_rounded,
              size: 22,
              color: foregroundColor,
            ),
          ),
      ],
    );
  }
}