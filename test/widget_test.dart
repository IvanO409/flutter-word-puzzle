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
    final queue = WorkQueue.from(
      crossword: crossword,
      candidateWords: ['art', 'cat'],
      startLocation: Location.at(0, 0),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workQueueProvider.overrideWith((ref) => Stream.value(queue)),
        ],
        child: const MaterialApp(home: CrosswordGeneratorApp()),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Crossword Generator'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('Permite abrir el menú y mostrar información', (tester) async {
    final crossword = Crossword.crossword(width: 40, height: 22);
    final queue = WorkQueue.from(
      crossword: crossword,
      candidateWords: ['cat'],
      startLocation: Location.at(0, 0),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workQueueProvider.overrideWith((ref) => Stream.value(queue)),
        ],
        child: const MaterialApp(home: CrosswordGeneratorApp()),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();
    expect(find.text('20 x 11'), findsOneWidget);
    expect(find.text('Display Info'), findsOneWidget);
    await tester.tap(find.text('Display Info'));
    await tester.pump();
    expect(find.text('Generation statistics'), findsOneWidget);
    // Cierra el panel, evitando un ticker activo en pruebas futuras.
    await tester.tap(find.byTooltip('Hide statistics'));
    await tester.pump();
    expect(find.text('Generation statistics'), findsNothing);
  });
}
