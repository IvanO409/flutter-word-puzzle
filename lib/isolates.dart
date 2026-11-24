import 'dart:async';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import 'model.dart';

// Representa una posible posición de una palabra.
typedef WordPlacement = (String word, Direction direction, Location location);

// Datos para evaluar un lote de candidatos.
typedef CandidateBatch = (Crossword crossword, List<WordPlacement> placements);

// Función independiente del proveedor Riverpod.
// Puede ejecutarse mediante compute.
Crossword? evaluateCandidates(CandidateBatch batch) {
  final (crossword, placements) = batch;

  for (final (word, direction, location) in placements) {
    final candidate = crossword.addWord(
      word: word,
      direction: direction,
      location: location,
    );

    if (candidate != null) {
      return candidate;
    }
  }

  return null;
}

// Generador asíncrono de crucigramas.
Stream<Crossword> exploreCrosswordSolutions({
  required Crossword crossword,
  required BuiltSet<String> wordList,
}) async* {
  final random = Random();

  final usableWords = wordList
      .where(
        (word) =>
            word.length <= min(12, max(crossword.width, crossword.height)),
      )
      .toList(growable: false);

  var current = crossword;

  // Mostrar primero la cuadrícula vacía.
  yield current;

  if (usableWords.isEmpty) {
    return;
  }

  final targetCells = (current.width * current.height * 0.8).ceil();

  const maxAttempts = 30000;
  const batchSize = 64;

  var attempts = 0;

  while (current.characters.length < targetCells && attempts < maxAttempts) {
    final placements = <WordPlacement>[];

    for (var i = 0; i < batchSize && attempts < maxAttempts; i++) {
      attempts++;

      final word = usableWords[random.nextInt(usableWords.length)];

      final direction = random.nextBool() ? Direction.across : Direction.down;

      final maxX = direction == Direction.across
          ? current.width - word.length
          : current.width - 1;

      final maxY = direction == Direction.down
          ? current.height - word.length
          : current.height - 1;

      if (maxX < 0 || maxY < 0) {
        continue;
      }

      final location = Location.at(
        random.nextInt(maxX + 1),
        random.nextInt(maxY + 1),
      );

      placements.add((word, direction, location));
    }

    if (placements.isEmpty) {
      continue;
    }

    // Evaluar candidatos fuera del aislamiento
    // principal en plataformas nativas.
    final candidate = await compute(evaluateCandidates, (current, placements));

    if (candidate != null) {
      current = candidate;

      // Enviar un estado válido a la interfaz.
      yield current;

      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }
}
