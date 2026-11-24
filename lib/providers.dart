import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'model.dart' as model;
import 'isolates.dart';

part 'providers.g.dart';

// =====================================================
// DICCIONARIO SOWPODS
// =====================================================

@riverpod
Future<BuiltSet<String>> wordList(Ref ref) async {
  final re = RegExp(r'^[a-z]+$');

  final words = await rootBundle.loadString('assets/words.txt');

  final filteredWords = const LineSplitter()
      .convert(words)
      .map((word) => word.toLowerCase().trim())
      .where((word) => word.length > 2)
      .where((word) => re.hasMatch(word));

  return BuiltSet<String>(filteredWords);
}

// =====================================================
// TAMAÑOS DEL CRUCIGRAMA
// =====================================================

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

// =====================================================
// CONTROL DEL TAMAÑO
// =====================================================

@Riverpod(keepAlive: true)
class Size extends _$Size {
  @override
  CrosswordSize build() {
    return CrosswordSize.medium;
  }

  void setSize(CrosswordSize size) {
    state = size;
  }
}

// =====================================================
// GENERADOR DEL CRUCIGRAMA
// =====================================================

@riverpod
Stream<model.Crossword> crossword(Ref ref) async* {
  // Observar el tamaño seleccionado.
  final selectedSize = ref.watch(sizeProvider);

  // Observar el diccionario.
  final dictionaryFuture = ref.watch(wordListProvider.future);

  final dictionary = await dictionaryFuture;

  // Crear cuadrícula inicial.
  final initialCrossword = model.Crossword.crossword(
    width: selectedSize.width,
    height: selectedSize.height,
  );

  // Delegar la generación a isolates.dart.
  yield* exploreCrosswordSolutions(
    crossword: initialCrossword,
    wordList: dictionary,
  );
}
