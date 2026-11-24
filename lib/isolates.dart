import 'dart:async';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import 'model.dart';
import 'utils.dart';

// La propuesta se valida de nuevo al incorporarse al tablero compartido.
typedef CandidateTask = (
  Crossword crossword,
  List<String> candidateWords,
  Location location,
  Direction direction,
);
typedef CandidateResult = (
  Location location,
  Direction direction,
  String? word,
  Location? start,
);
typedef GenerationTask = (WorkQueue queue, int maxWorkerCount);

// Cada trabajador prueba hasta 1000 palabras durante un máximo de 10 segundos.
CandidateResult _generateCandidate(CandidateTask task) {
  final (crossword, candidateWords, location, direction) = task;
  final watch = Stopwatch()..start();
  final letter = crossword.characters[location]?.character;
  for (final word in candidateWords.take(1000)) {
    if (watch.elapsed >= const Duration(seconds: 10)) break;
    if (letter == null) {
      final candidate = crossword.addWord(
        location: location,
        word: word,
        direction: direction,
      );
      if (candidate != null) return (location, direction, word, location);
      continue;
    }
    for (var i = 0; i < word.length; i++) {
      if (watch.elapsed >= const Duration(seconds: 10)) break;
      if (word[i] != letter) continue;
      final start = direction == Direction.across
          ? location.leftOffset(i)
          : location.upOffset(i);
      final candidate = crossword.addWord(
        location: start,
        word: word,
        direction: direction,
      );
      if (candidate != null) return (location, direction, word, start);
    }
  }
  return (location, direction, null, null);
}

// Un lote distribuye ubicaciones distintas y reúne sus resultados.
Future<WorkQueue> _generate(GenerationTask task) async {
  final (queue, maxWorkerCount) = task;
  if (queue.isCompleted) return queue;
  final random = Random();
  final locations = queue.locationsToTry.keys.toList()..shuffle(random);
  final workerLimit = maxWorkerCount < 1
      ? 1
      : (maxWorkerCount > 128 ? 128 : maxWorkerCount);
  final selected = locations.take(workerLimit).toList();
  final candidateGeneratorFutures = <Future<CandidateResult>>[];

  for (final location in selected) {
    final direction = queue.locationsToTry[location]!;
    final letter = queue.crossword.characters[location]?.character;
    final words = queue.candidateWords.where((word) {
      if (letter == null) return word.length <= queue.crossword.width;
      return word.contains(letter);
    }).toList()..shuffle(random);

    candidateGeneratorFutures.add(
      compute(_generateCandidate, (
        queue.crossword,
        words.take(1000).toList(),
        location,
        direction,
      )),
    );
  }

  final results = await candidateGeneratorFutures.wait;
  var updated = queue;
  for (final (location, direction, word, start) in results) {
    if (!updated.locationsToTry.containsKey(location)) continue;
    if (word == null || start == null) {
      updated = updated.remove(location);
      continue;
    }
    // Los trabajadores buscaron sobre la misma instantánea. Se vuelve a
    // comprobar cada propuesta antes de incorporarla, evitando colisiones.
    final next = updated.crossword.addWord(
      location: start,
      word: word,
      direction: direction,
    );
    if (next != null) {
      updated = updated.updateFrom(next);
    }
    // Una colisión con otra propuesta no convierte la ubicación en mala.
  }
  return updated;
}

Stream<WorkQueue> exploreCrosswordSolutions({
  required Crossword crossword,
  required BuiltSet<String> wordList,
  required int maxWorkerCount,
}) async* {
  final watch = Stopwatch()..start();
  var queue = WorkQueue.from(
    crossword: crossword,
    candidateWords: wordList,
    startLocation: Location.at(0, 0),
  );
  yield queue;
  final target = (crossword.width * crossword.height * 0.8).ceil();
  try {
    while (!queue.isCompleted && queue.crossword.characters.length < target) {
      queue = await compute(_generate, (queue, maxWorkerCount));
      yield queue;
      await Future<void>.delayed(Duration.zero);
    }
  } finally {
    watch.stop();
    debugPrint(
      'Generación: ${watch.elapsed.formatted} | '
      'palabras: ${queue.crossword.words.length} | '
      'descartadas: ${queue.badLocations.length} | '
      'trabajadores: $maxWorkerCount',
    );
  }
}
