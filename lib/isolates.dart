import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import 'model.dart';
import 'utils.dart';

typedef SearchTask = (
  Crossword crossword,
  Location location,
  Direction direction,
  List<String> words,
);

// Función de nivel superior, segura para compute (sin capturar Ref).
Crossword? evaluateCandidates(SearchTask task) {
  final (crossword, location, direction, words) = task;
  final target = crossword.characters[location];
  if (target == null) {
    for (final word in words) {
      final result = crossword.addWord(
        location: location,
        word: word,
        direction: direction,
      );
      if (result != null) return result;
    }
    return null;
  }
  for (final word in words.take(1000)) {
    for (var i = 0; i < word.length; i++) {
      if (word[i] != target.character) continue;
      final start = direction == Direction.across
          ? location.leftOffset(i)
          : location.upOffset(i);
      final candidate = crossword.addWord(
        location: start,
        word: word,
        direction: direction,
      );
      if (candidate != null) return candidate;
    }
  }
  return null;
}

Stream<WorkQueue> exploreCrosswordSolutions({
  required Crossword crossword,
  required BuiltSet<String> wordList,
}) async* {
  final stopwatch = Stopwatch()..start();
  final random = Random();
  var queue = WorkQueue.from(
    crossword: crossword,
    candidateWords: wordList,
    startLocation: Location.at(0, 0),
  );
  yield queue;
  final target = (crossword.width * crossword.height * 0.8).ceil();
  try {
    while (!queue.isCompleted && queue.crossword.characters.length < target) {
      final locations = queue.locationsToTry.keys.toList(growable: false);
      final location = locations[random.nextInt(locations.length)];
      final direction = queue.locationsToTry[location]!;
      final existing = queue.crossword.characters[location];
      final words = queue.candidateWords
          .where(
            (word) => existing == null
                ? word.length <= queue.crossword.width
                : word.contains(existing.character),
          )
          .toList();
      words.shuffle(random);
      final candidate = await compute(evaluateCandidates, (
        queue.crossword,
        location,
        direction,
        words.take(1000).toList(),
      ));
      if (candidate == null) {
        queue = queue.remove(location);
      } else {
        queue = queue.updateFrom(candidate);
      }
      // Emitir también los rechazos: la telemetría mostrará badLocations.
      yield queue;
      await Future<void>.delayed(Duration.zero);
    }
  } finally {
    stopwatch.stop();
    debugPrint(
      'Generación: ${stopwatch.elapsed.formatted} | '
      'palabras: ${queue.crossword.words.length} | '
      'descartadas: ${queue.badLocations.length}',
    );
  }
}
