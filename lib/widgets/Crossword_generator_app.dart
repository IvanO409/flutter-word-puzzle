
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class CrosswordGeneratorApp extends ConsumerWidget {
  const CrosswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordListAsync = ref.watch(wordListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crossword Generator'),
        backgroundColor:
            Theme.of(context).colorScheme.primaryContainer,
      ),
      body: wordListAsync.when(
        data: (wordList) {
          final words = wordList.toList(growable: false);

          return ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(words[index]),
              );
            },
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(
              'Error al cargar palabras: $error',
            ),
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
