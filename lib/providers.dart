import 'dart:async';
import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'isolates.dart';
import 'model.dart' as model;

part 'providers.g.dart';

@riverpod
Future<BuiltSet<String>> wordList(Ref ref) async {
  final contents = await rootBundle.loadString('assets/words.txt');
  final expression = RegExp(r'^[a-z]+$');
  return BuiltSet<String>(
    const LineSplitter()
        .convert(contents)
        .map((word) => word.toLowerCase().trim())
        .where((word) => word.length >= 3 && expression.hasMatch(word)),
  );
}

enum CrosswordSize {
  small(20, 11),
  medium(40, 22),
  large(80, 44),
  xlarge(160, 88),
  xxlarge(500, 500);

  const CrosswordSize(this.width, this.height);
  final int width;
  final int height;
  String get label => '$width x $height';
}

@Riverpod(keepAlive: true)
class Size extends _$Size {
  @override
  CrosswordSize build() => CrosswordSize.small;
  void setSize(CrosswordSize size) => state = size;
}

const backgroundWorkerCount = 4;

@riverpod
Stream<model.WorkQueue> workQueue(Ref ref) async* {
  final size = ref.watch(sizeProvider);
  final words = await ref.watch(wordListProvider.future);
  final initial = model.Crossword.crossword(
    width: size.width,
    height: size.height,
  );
  yield* exploreCrosswordSolutions(
    crossword: initial,
    wordList: words,
    maxWorkerCount: backgroundWorkerCount,
  );
}

model.CrosswordPuzzleGame _puzzleFromCrosswordTrampoline(
  (model.Crossword, BuiltSet<String>) args,
) =>
    model.CrosswordPuzzleGame.from(crossword: args.$1, candidateWords: args.$2);

model.CrosswordPuzzleGame? _puzzleSelectWordTrampoline(
  (model.CrosswordPuzzleGame, model.Location, String, model.Direction) args,
) => args.$1.selectWord(location: args.$2, word: args.$3, direction: args.$4);

@riverpod
class Puzzle extends _$Puzzle {
  @override
  Future<model.CrosswordPuzzleGame> build() async {
    final asyncQueue = ref.watch(workQueueProvider);
    final queue = asyncQueue.value;
    final size = ref.watch(sizeProvider);
    final coverageTarget = (size.width * size.height * 0.8).ceil();
    // Mientras llegan resultados parciales, el generador sigue visible.
    if (queue == null ||
        (!queue.isCompleted &&
            queue.crossword.characters.length < coverageTarget)) {
      return Completer<model.CrosswordPuzzleGame>().future;
    }
    if (queue.crossword.words.isEmpty) {
      throw StateError('No se pudo generar un crucigrama. Intenta de nuevo.');
    }
    final dictionary = await ref.watch(wordListProvider.future);
    return compute(_puzzleFromCrosswordTrampoline, (
      queue.crossword,
      dictionary,
    ));
  }

  Future<void> selectWord({
    required model.Location location,
    required String word,
    required model.Direction direction,
  }) async {
    final current = state.value;
    if (current == null) return;
    final next = await compute(_puzzleSelectWordTrampoline, (
      current,
      location,
      word,
      direction,
    ));
    if (next != null) state = AsyncData(next);
  }
}
