
import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
Future<BuiltSet<String>> wordList(Ref ref) async {
  final re = RegExp(r'^[a-z]+$');

  final words = await rootBundle.loadString(
    'assets/words.txt',
  );

  final filteredWords = const LineSplitter()
      .convert(words)
      .map((word) => word.toLowerCase().trim())
      .where((word) => word.length > 2)
      .where((word) => re.hasMatch(word));

  return BuiltSet<String>(filteredWords);
}
