import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import 'model.dart';
import 'utils.dart';

// =====================================================
// MENSAJE ENVIADO A COMPUTE
// =====================================================

typedef SearchTask = (
  Crossword crossword,
  Location location,
  Direction direction,
  List<String> words,
);

// =====================================================
// EVALUACIÓN DE CANDIDATOS
// =====================================================

// Función de nivel superior para evitar capturar
// objetos internos de Riverpod.
Crossword? evaluateCandidates(SearchTask task) {
  final (crossword, location, direction, words) = task;

  final target = crossword.characters[location];

  // Caso especial: primera palabra.
  if (target == null) {
    for (final word in words) {
      final result = crossword.addWord(
        location: location,
        word: word,
        direction: direction,
      );

      if (result != null) {
        return result;
      }
    }

    return null;
  }

  var tryCount = 0;

  for (final word in words) {
    tryCount++;

    if (tryCount > 1000) {
      break;
    }

    // Buscar todas las posiciones donde la palabra
    // contiene la letra de intersección.
    for (var index = 0; index < word.length; index++) {
      if (word[index] != target.character) {
        continue;
      }

      final startLocation = switch (direction) {
        Direction.across => location.leftOffset(index),
        Direction.down => location.upOffset(index),
      };

      final candidate = crossword.addWord(
        location: startLocation,
        word: word,
        direction: direction,
      );

      if (candidate != null) {
        return candidate;
      }
    }
  }

  return null;
}

// =====================================================
// BÚSQUEDA GUIADA CON WORKQUEUE
// =====================================================

Stream<Crossword> exploreCrosswordSolutions({
  required Crossword crossword,
  required BuiltSet<String> wordList,
}) async* {
  final stopwatch = Stopwatch()..start();
  final random = Random();

  var workQueue = WorkQueue.from(
    crossword: crossword,
    candidateWords: wordList,
    startLocation: Location.at(0, 0),
  );

  // Enviar el estado inicial a la interfaz.
  yield workQueue.crossword;

  final totalCells = crossword.width * crossword.height;
  final targetCells = (totalCells * 0.80).ceil();

  var successfulPlacements = 0;
  var rejectedLocations = 0;

  try {
    while (!workQueue.isCompleted &&
        workQueue.crossword.characters.length < targetCells) {
      // Elegir una intersección pendiente.
      final locations = workQueue.locationsToTry.keys.toList();

      if (locations.isEmpty) {
        break;
      }

      final location = locations[random.nextInt(locations.length)];

      final direction = workQueue.locationsToTry[location]!;

      final target = workQueue.crossword.characters[location];

      // Filtrar palabras que contienen la letra
      // requerida para esta intersección.
      final candidates = workQueue.candidateWords.where((word) {
        if (target == null) {
          return word.length <= workQueue.crossword.width;
        }

        return word.contains(target.character);
      }).toList();

      // Variar el orden de búsqueda.
      candidates.shuffle(random);

      // Probar como máximo 1000 palabras.
      final selectedWords = candidates.take(1000).toList(growable: false);

      if (selectedWords.isEmpty) {
        workQueue = workQueue.remove(location);
        rejectedLocations++;
        continue;
      }

      // compute usa aislamiento separado en las
      // plataformas nativas compatibles.
      final result = await compute(evaluateCandidates, (
        workQueue.crossword,
        location,
        direction,
        selectedWords,
      ));

      if (result != null) {
        // Actualizar cola con el crucigrama válido.
        workQueue = workQueue.updateFrom(result);

        successfulPlacements++;

        // Refrescar la cuadrícula.
        yield workQueue.crossword;
      } else {
        // No hubo solución: registrar ubicación fallida.
        workQueue = workQueue.remove(location);
        rejectedLocations++;
      }

      // Permitir que el ciclo de eventos procese
      // actualizaciones de interfaz.
      await Future<void>.delayed(Duration.zero);
    }
  } finally {
    stopwatch.stop();

    debugPrint('======================================');
    debugPrint('ETAPA 7 - GENERACIÓN DE CRUCIGRAMAS');
    debugPrint('Tiempo: ${stopwatch.elapsed.formatted}');
    debugPrint('Palabras colocadas: $successfulPlacements');
    debugPrint('Ubicaciones descartadas: $rejectedLocations');
    debugPrint('Celdas ocupadas: ${workQueue.crossword.characters.length}');
    debugPrint('======================================');
  }
}
