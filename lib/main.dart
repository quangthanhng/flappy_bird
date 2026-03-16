import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game/flappy_game.dart';
import 'game/game_audio.dart';
import 'game/game_controller.dart';
import 'game/game_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final audio = GameAudio();
  await audio.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        gameAudioProvider.overrideWithValue(audio),
      ],
      child: const FlappyApp(),
    ),
  );
}

class FlappyApp extends StatelessWidget {
  const FlappyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy Bird Riverpod',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final FlappyGame _game;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(gameControllerProvider.notifier);
    _game = FlappyGame(controller: controller);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GameState>(gameControllerProvider, (previous, next) {
      if (previous?.phase != next.phase) {
        if (next.phase == GamePhase.menu) {
          _game.resetForMenu();
        }
        if (next.phase == GamePhase.ready) {
          _game.resetForNewRound();
        }
      }
    });

    final state = ref.watch(gameControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),
          if (state.phase == GamePhase.menu) _MenuOverlay(state: state),
          if (state.phase == GamePhase.ready && state.showTutorial)
            const _TutorialOverlay(),
          if (state.phase == GamePhase.gameOver) _GameOverOverlay(state: state),
          if (state.phase != GamePhase.menu) _HudOverlay(state: state),
        ],
      ),
    );
  }
}

class _MenuOverlay extends ConsumerWidget {
  const _MenuOverlay({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xAA000000),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'FLAPPY BIRD',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Best: ${state.bestScore}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(gameControllerProvider.notifier).startGame();
                  },
                  child: const Text('Start'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    ref.read(gameControllerProvider.notifier).toggleMute();
                  },
                  child: Text(state.muted ? 'Sound: Off' : 'Sound: On'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorialOverlay extends StatelessWidget {
  const _TutorialOverlay();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xCC000000),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tap to Flap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Avoid the pipes',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HudOverlay extends ConsumerWidget {
  const _HudOverlay({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Score: ${state.score}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(gameControllerProvider.notifier).toggleMute();
            },
            icon: Icon(
              state.muted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameOverOverlay extends ConsumerWidget {
  const _GameOverOverlay({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xBB000000),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Game Over',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Score: ${state.score}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'Best: ${state.bestScore}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    ref.read(gameControllerProvider.notifier).restart();
                  },
                  child: const Text('Restart'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    ref.read(gameControllerProvider.notifier).goToMenu();
                  },
                  child: const Text('Main Menu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
