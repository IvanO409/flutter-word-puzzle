import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'model.dart' as model;
import 'utils.dart';

part 'providers.g.dart';

@riverpod
Future<BuiltSet<String>> wordList(Ref ref) async {
  final re = RegExp(r'^[a-z]+$');
  final words = await rootBundle.loadString('assets/words.txt');

  final filtered = const LineSplitter()
      .convert(words)
      .map((word) => word.toLowerCase().trim())
      .where((word) => word.length > 2)
      .where((word) => re.hasMatch(word));

  return BuiltSet<String>(filtered);
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

  void setSize(CrosswordSize size) {
    state = size;
  }
}

@riverpod
Stream<model.Crossword> crossword(Ref ref) async* {
  final selectedSize = ref.watch(sizeProvider);
  final dictionary = await ref.watch(wordListProvider.future);

  final random = Random();

  final words = dictionary
      .where(
        (word) =>
            word.length <=
            min(12, max(selectedSize.width, selectedSize.height)),
      )
      .toBuiltSet();

  var current = model.Crossword.crossword(
    width: selectedSize.width,
    height: selectedSize.height,
  );

  yield current;

  final totalCells = selectedSize.width * selectedSize.height;
  final targetCells = (totalCells * 0.8).ceil();

  while (current.characters.length < targetCells) {
    if (words.isEmpty) break;

    final word = words.randomElement(random);
    final direction = random.nextBool()
        ? model.Direction.across
        : model.Direction.down;

    final maxX = direction == model.Direction.across
        ? selectedSize.width - word.length
        : selectedSize.width - 1;

    final maxY = direction == model.Direction.down
        ? selectedSize.height - word.length
        : selectedSize.height - 1;

    if (maxX < 0 || maxY < 0) continue;

    final location = model.Location.at(
      random.nextInt(maxX + 1),
      random.nextInt(maxY + 1),
    );

    current = current.addWord(
      location: location,
      word: word,
      direction: direction,
    );

    yield current;

    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
