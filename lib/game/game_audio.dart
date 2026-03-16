import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

class GameAudio {
  bool _ready = false;

  bool get ready => _ready;

  Future<void> init() async {
    try {
      await FlameAudio.audioCache.loadAll(['flap.wav', 'score.wav', 'hit.wav']);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  void playFlap() {
    if (!_ready) return;
    unawaited(FlameAudio.play('flap.wav'));
  }

  void playScore() {
    if (!_ready) return;
    unawaited(FlameAudio.play('score.wav'));
  }

  void playHit() {
    if (!_ready) return;
    unawaited(FlameAudio.play('hit.wav'));
  }
}
