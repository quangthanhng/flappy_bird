enum GamePhase { menu, ready, playing, gameOver }

class GameState {
  const GameState({
    required this.phase,
    required this.score,
    required this.bestScore,
    required this.muted,
    required this.showTutorial,
  });

  final GamePhase phase;
  final int score;
  final int bestScore;
  final bool muted;
  final bool showTutorial;

  GameState copyWith({
    GamePhase? phase,
    int? score,
    int? bestScore,
    bool? muted,
    bool? showTutorial,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      muted: muted ?? this.muted,
      showTutorial: showTutorial ?? this.showTutorial,
    );
  }

  static GameState initial({required int bestScore}) {
    return GameState(
      phase: GamePhase.menu,
      score: 0,
      bestScore: bestScore,
      muted: false,
      showTutorial: true,
    );
  }
}
