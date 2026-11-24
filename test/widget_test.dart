
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/providers.dart';
import 'package:generate_crossword/widgets/crossword_generator_app.dart';

void main() {
  testWidgets('Muestra las palabras del diccionario', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wordListProvider.overrideWith(
            (ref) async => BuiltSet<String>([
              'apple',
              'banana',
              'orange',
            ]),
          ),
        ],
        child: const MaterialApp(
          home: CrosswordGeneratorApp(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Crossword Generator'), findsOneWidget);
    expect(find.text('apple'), findsOneWidget);
    expect(find.text('banana'), findsOneWidget);
    expect(find.text('orange'), findsOneWidget);
  });
}
