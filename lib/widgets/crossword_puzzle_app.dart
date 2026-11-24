import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'crossword_generator_widget.dart';
import 'crossword_puzzle_widget.dart';
import 'puzzle_completed_widget.dart';

class CrosswordPuzzleApp extends ConsumerWidget {
  const CrosswordPuzzleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzle = ref.watch(puzzleProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crossword Puzzle'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          PopupMenuButton<CrosswordSize>(
            tooltip: 'Grid size',
            icon: const Icon(Icons.settings),
            initialValue: ref.watch(sizeProvider),
            onSelected: (size) => ref.read(sizeProvider.notifier).setSize(size),
            itemBuilder: (context) => [
              for (final size in CrosswordSize.values)
                PopupMenuItem(value: size, child: Text(size.label)),
            ],
          ),
        ],
      ),
      body: puzzle.when(
        data: (game) => game.solved
            ? PuzzleCompletedWidget(game: game)
            : CrosswordPuzzleWidget(game: game),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  ref.invalidate(workQueueProvider);
                  ref.invalidate(puzzleProvider);
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
        loading: () => const CrosswordGeneratorWidget(),
      ),
    );
  }
}
