// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flappy_bird/main.dart';
import 'package:flappy_bird/game/game_audio.dart';
import 'package:flappy_bird/game/game_controller.dart';

void main() {
  testWidgets('Shows menu on launch', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final audio = GameAudio();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          gameAudioProvider.overrideWithValue(audio),
        ],
        child: const FlappyApp(),
      ),
    );

    expect(find.text('FLAPPY BIRD'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });
}
