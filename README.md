# flappy_bird

Flappy Bird built with Flutter + Riverpod + Flame.

## Features

- Riverpod state management for menu, score, and sound toggle.
- Flame game loop for physics and rendering.
- CustomPainter-style bird (rounded body, no external assets).
- Menu, tutorial hint, in-game HUD, and game over screen.
- Best score persisted with shared_preferences.
- Simple system click sound for flap and score.

## Controls

- Tap to start.
- Tap to flap while playing.

## Project Structure

- lib/main.dart: App shell and overlays.
- lib/game/game_state.dart: GameState + GamePhase.
- lib/game/game_controller.dart: Riverpod controller + best score storage.
- lib/game/flappy_game.dart: Flame game loop and rendering.
- lib/game/components/bird_component.dart: Custom rounded bird.
- lib/game/components/pipe_pair_component.dart: Pipe rendering + collision.

## Run

1. flutter pub get
2. flutter run
