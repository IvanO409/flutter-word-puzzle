import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'isolates.dart';
import 'model.dart' as model;

part 'providers.g.dart';

@riverpod
Future<BuiltSet<String>> wordList(Ref ref) async {
  final words = await rootBundle.loadString('assets/words.txt');
  final re = RegExp(r'^[a-z]+$');
  return BuiltSet<String>(
    const LineSplitter()
        .convert(words)
        .map((word) => word.toLowerCase().trim())
        .where((word) => word.length > 2 && re.hasMatch(word)),
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
  CrosswordSize build() => CrosswordSize.medium;
  void setSize(CrosswordSize size) => state = size;
}

enum BackgroundWorkers {
  one(1),
  two(2),
  four(4),
  eight(8),
  sixteen(16),
  thirtyTwo(32),
  sixtyFour(64),
  oneTwentyEight(128);

  const BackgroundWorkers(this.count);
  final int count;
  String get label => '$count';
}

@Riverpod(keepAlive: true)
class WorkerCount extends _$WorkerCount {
  @override
  BackgroundWorkers build() => BackgroundWorkers.four;
  void setCount(BackgroundWorkers value) => state = value;
}

@Riverpod(keepAlive: true)
class StartTime extends _$StartTime {
  @override
  DateTime? build() => null;
  void start() => state = DateTime.now();
  void clear() => state = null;
}

@Riverpod(keepAlive: true)
class EndTime extends _$EndTime {
  @override
  DateTime? build() => null;
  void finish() => state = DateTime.now();
  void clear() => state = null;
}

@Riverpod(keepAlive: true)
class ShowDisplayInfo extends _$ShowDisplayInfo {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void setVisible(bool value) => state = value;
}

@riverpod
Stream<model.WorkQueue> workQueue(Ref ref) async* {
  final size = ref.watch(sizeProvider);
  final workers = ref.watch(workerCountProvider);
  final dictionary = await ref.watch(wordListProvider.future);
  ref.read(endTimeProvider.notifier).clear();
  ref.read(startTimeProvider.notifier).start();
  final crossword = model.Crossword.crossword(
    width: size.width,
    height: size.height,
  );
  try {
    yield* exploreCrosswordSolutions(
      crossword: crossword,
      wordList: dictionary,
      maxWorkerCount: workers.count,
    );
  } finally {
    // El proveedor puede ser invalidado si el usuario cambia el tamaño.
    if (ref.mounted) {
      ref.read(endTimeProvider.notifier).finish();
    }
  }
}

const double _estimatedTotalCoverage = 0.54;

@riverpod
Duration expectedRemainingTime(Ref ref) {
  final start = ref.watch(startTimeProvider);
  final end = ref.watch(endTimeProvider);
  final queue = ref.watch(workQueueProvider).value;
  if (start == null || end != null || queue == null) return Duration.zero;
  final total = queue.crossword.width * queue.crossword.height;
  if (total <= 0) return Duration.zero;
  final coverage = queue.crossword.characters.length / total;
  if (coverage <= 0) return Duration.zero;
  final elapsedMs = DateTime.now().difference(start).inMilliseconds;
  final remainingMs =
      elapsedMs * (_estimatedTotalCoverage - coverage) / coverage;
  if (!remainingMs.isFinite || remainingMs <= 0) return Duration.zero;
  return Duration(milliseconds: remainingMs.round());
}

@riverpod
class DisplayInfo extends _$DisplayInfo {
  @override
  model.DisplayInfo build() {
    final queue = ref.watch(workQueueProvider).value;
    if (queue == null) return model.DisplayInfo.empty;
    return model.DisplayInfo.from(workQueue: queue);
  }
}
