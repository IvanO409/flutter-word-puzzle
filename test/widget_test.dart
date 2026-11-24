import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:generate_crossword/model.dart';
import 'package:generate_crossword/providers.dart';
import 'package:generate_crossword/widgets/crossword_generator_app.dart';

void main() {
  testWidgets('Muestra la cuadrícula y el menú', (tester) async {
    final crossword = Crossword.crossword(width: 20, height: 11).addWord(
      location: Location.at(0, 0),
      word: 'dart',
      direction: Direction.across,
    )!;

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

  testWidgets('Permite abrir el menú de tamaños', (tester) async {
    final crossword = Crossword.crossword(width: 40, height: 22);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          crosswordProvider.overrideWith((ref) => Stream.value(crossword)),
        ],
        child: const MaterialApp(home: CrosswordGeneratorApp()),
      ),
    );

    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('20 x 11'), findsOneWidget);
    expect(find.text('40 x 22'), findsOneWidget);
  });
}
