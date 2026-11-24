import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:generate_crossword/model.dart';
import 'package:generate_crossword/providers.dart';
import 'package:generate_crossword/widgets/crossword_generator_app.dart';

void main() {
  test('Agrega palabras al crucigrama', () {
    final crossword = Crossword.crossword(width: 20, height: 11).addWord(
      location: Location.at(1, 1),
      word: 'flutter',
      direction: Direction.across,
    );

    expect(crossword.words.length, 1);

    expect(crossword.characters[Location.at(1, 1)]?.character, 'f');

    expect(crossword.characters[Location.at(7, 1)]?.character, 'r');
  });

  testWidgets('Muestra la cuadrícula y el menú', (tester) async {
    final crossword = Crossword.crossword(width: 20, height: 11).addWord(
      location: Location.at(0, 0),
      word: 'dart',
      direction: Direction.across,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          crosswordProvider.overrideWith((ref) => Stream.value(crossword)),
        ],
        child: const MaterialApp(home: CrosswordGeneratorApp()),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Crossword Generator'), findsOneWidget);

    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
