import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/bird_component.dart';
import 'components/pipe_pair_component.dart';
import 'game_controller.dart';
import 'game_state.dart';

class FlappyGame extends FlameGame with TapCallbacks {
  FlappyGame({required this.controller});

  final GameController controller;

  final BirdComponent _bird = BirdComponent();
  final List<PipePair> _pipes = [];

  Vector2 _screenSize = Vector2.zero();
  double _groundHeight = 90;
  double _spawnTimer = 0;
  double _bobTime = 0;

  final double _gravity = 900;
  final double _flapVelocity = -320;
  final double _pipeSpeed = 170;
  final double _spawnInterval = 1.4;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_bird);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _screenSize = size;
    _groundHeight = max<double>(70.0, size.y * 0.12);
    resetForMenu();
  }

  void resetForMenu() {
    if (_screenSize.x == 0 || _screenSize.y == 0) {
      return;
    }
    _pipes.clear();
    _spawnTimer = 0;
    _bobTime = 0;
    _bird.velocity = 0;
    _bird.angle = 0;
    _bird.position = _birdStart;
  }

  void resetForNewRound() {
    resetForMenu();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final phase = controller.snapshot.phase;

    if (phase == GamePhase.menu) {
      controller.startGame();
      return;
    }

    if (phase == GamePhase.ready) {
      controller.startPlaying();
      _flap();
      return;
    }

    if (phase == GamePhase.playing) {
      _flap();
    }
  }

  void _flap() {
    _bird.velocity = _flapVelocity;
    controller.playFlapSound();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_screenSize.x == 0 || _screenSize.y == 0) {
      return;
    }

    final phase = controller.snapshot.phase;

    if (phase == GamePhase.ready) {
      _bobTime += dt;
      _bird.position = _birdStart + Vector2(0, sin(_bobTime * 3) * 6);
      return;
    }

    if (phase != GamePhase.playing) {
      return;
    }

    _bird.velocity += _gravity * dt;
    _bird.position.y += _bird.velocity * dt;
    _bird.angle = (_bird.velocity / 500).clamp(-0.7, 0.7);

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnPipe();
    }

    for (final pipe in _pipes) {
      pipe.x -= _pipeSpeed * dt;
      if (!pipe.passed && pipe.x + pipe.width < _bird.position.x) {
        pipe.passed = true;
        controller.addScore();
      }
    }

    _pipes.removeWhere((pipe) => pipe.x + pipe.width < -20);

    final birdRect = _bird.hitbox;
    if (_hitGround(birdRect) || _hitCeiling(birdRect)) {
      controller.playHitSound();
      controller.gameOver();
      return;
    }

    for (final pipe in _pipes) {
      if (pipe.collidesWith(birdRect, _groundHeight, _screenSize.y)) {
        controller.playHitSound();
        controller.gameOver();
        return;
      }
    }
  }

  bool _hitGround(Rect birdRect) {
    return birdRect.bottom >= _screenSize.y - _groundHeight;
  }

  bool _hitCeiling(Rect birdRect) {
    return birdRect.top <= 0;
  }

  void _spawnPipe() {
    final gapHeight = max<double>(120.0, _screenSize.y * 0.22);
    final minCenter = gapHeight * 0.8;
    final maxCenter = _screenSize.y - _groundHeight - gapHeight * 0.8;
    final gapCenter =
        minCenter + Random().nextDouble() * (maxCenter - minCenter);

    _pipes.add(
      PipePair(
        x: _screenSize.x + 40,
        gapCenter: gapCenter,
        width: 64,
        gapHeight: gapHeight,
      ),
    );
  }

  Vector2 get _birdStart {
    return Vector2(_screenSize.x * 0.3, _screenSize.y * 0.42);
  }

  @override
  void render(Canvas canvas) {
    _drawBackground(canvas);
    for (final pipe in _pipes) {
      pipe.render(canvas, _groundHeight, _screenSize.y);
    }
    super.render(canvas);
    _drawGround(canvas);
  }

  void _drawBackground(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, _screenSize.x, _screenSize.y);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF7DD3FC), Color(0xFF38BDF8)],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawGround(Canvas canvas) {
    final rect = Rect.fromLTWH(
      0,
      _screenSize.y - _groundHeight,
      _screenSize.x,
      _groundHeight,
    );
    final groundPaint = Paint()..color = const Color(0xFFD6A354);
    final grassPaint = Paint()..color = const Color(0xFF2E7D32);

    canvas.drawRect(rect, groundPaint);
    canvas.drawRect(Rect.fromLTWH(0, rect.top, _screenSize.x, 8), grassPaint);
  }
}
