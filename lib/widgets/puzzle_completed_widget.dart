import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model.dart';
import '../providers.dart';

class PuzzleCompletedWidget extends ConsumerWidget {
  const PuzzleCompletedWidget({super.key, required this.game});
  final CrosswordPuzzleGame game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, size: 90, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            'Puzzle Completed!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text('${game.crossword.words.length} words solved'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              ref.invalidate(workQueueProvider);
              ref.invalidate(puzzleProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Play again'),
          ),
        ],
      ),
    );
  }
}
