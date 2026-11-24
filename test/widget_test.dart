import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/widgets/crossword_puzzle_app.dart';

void main() {
  testWidgets('La pantalla principal muestra el juego y configuración', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CrosswordPuzzleApp())),
    );
    expect(find.text('Crossword Puzzle'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
