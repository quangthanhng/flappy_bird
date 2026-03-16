import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_audio.dart';
import 'game_state.dart';

const _bestScoreKey = 'bestScore';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.');
});

final gameAudioProvider = Provider<GameAudio>((ref) {
  throw UnimplementedError('GameAudio must be overridden in main.');
});

final gameControllerProvider = StateNotifierProvider<GameController, GameState>(
  (ref) => GameController(
    ref.read(sharedPreferencesProvider),
    ref.read(gameAudioProvider),
  ),
);

class GameController extends StateNotifier<GameState> {
  GameController(this._prefs, this._audio)
    : super(GameState.initial(bestScore: 0)) {
    final bestScore = _prefs.getInt(_bestScoreKey) ?? 0;
    state = state.copyWith(bestScore: bestScore);
  }

  final SharedPreferences _prefs;
  final GameAudio _audio;

  GameState get snapshot => state;

  void startGame() {
    state = state.copyWith(
      phase: GamePhase.ready,
      score: 0,
      showTutorial: true,
    );
  }

  void startPlaying() {
    state = state.copyWith(phase: GamePhase.playing, showTutorial: false);
  }

  void addScore() {
    final nextScore = state.score + 1;
    var nextBest = state.bestScore;

    if (nextScore > state.bestScore) {
      nextBest = nextScore;
      _prefs.setInt(_bestScoreKey, nextBest);
    }

    state = state.copyWith(score: nextScore, bestScore: nextBest);
    _playScore();
  }

  void gameOver() {
    if (state.phase == GamePhase.gameOver) {
      return;
    }
    state = state.copyWith(phase: GamePhase.gameOver);
  }

  void restart() {
    startGame();
  }

  void goToMenu() {
    state = state.copyWith(phase: GamePhase.menu, score: 0);
  }

  void toggleMute() {
    state = state.copyWith(muted: !state.muted);
  }

  void playFlapSound() {
    if (!state.muted) {
      _playFlap();
    }
  }

  void playHitSound() {
    if (!state.muted) {
      _playHit();
    }
  }

  void _playFlap() {
    if (_audio.ready) {
      _audio.playFlap();
    }
  }

  void _playScore() {
    if (_audio.ready) {
      _audio.playScore();
    }
  }

  void _playHit() {
    if (_audio.ready) {
      _audio.playHit();
    }
  }
}
