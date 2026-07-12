enum GameCardState {
  hidden,
  revealed,
  matched,
}

class GameCard {
  const GameCard({
    required this.id,
    required this.word,
    this.state = GameCardState.hidden,
  });

  final String id;
  final String word;
  final GameCardState state;

  GameCard withState(GameCardState newState) {
    return GameCard(
      id: id,
      word: word,
      state: newState,
    );
  }
}