import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../model.dart';
import '../providers.dart';

class CrosswordPuzzleWidget extends ConsumerWidget {
  const CrosswordPuzzleWidget({super.key, required this.game});
  final CrosswordPuzzleGame game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = game.crosswordFromSelectedWords;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Words: ${game.selectedWords.length}/${game.crossword.words.length} — Tap a cell to choose a word',
          ),
        ),
        Expanded(
          child: TableView.builder(
            rowCount: game.crossword.height,
            columnCount: game.crossword.width,
            rowBuilder: (_) =>
                const TableSpan(extent: FixedTableSpanExtent(34)),
            columnBuilder: (_) =>
                const TableSpan(extent: FixedTableSpanExtent(34)),
            cellBuilder: (context, vicinity) {
              final location = Location.at(vicinity.column, vicinity.row);
              final target = game.crossword.characters[location];
              final chosen = board.characters[location];
              return TableViewCell(
                child: target == null
                    ? const SizedBox.expand()
                    : _PuzzleCell(
                        game: game,
                        location: location,
                        character: chosen?.character.toUpperCase() ?? '',
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PuzzleCell extends StatelessWidget {
  const _PuzzleCell({
    required this.game,
    required this.location,
    required this.character,
  });
  final CrosswordPuzzleGame game;
  final Location location;
  final String character;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entries = <(Location, Direction, String)>{};
    final target = game.crossword.characters[location]!;
    if (target.acrossWord case final CrosswordWord word) {
      entries.add((word.location, Direction.across, 'Across'));
    }
    if (target.downWord case final CrosswordWord word) {
      entries.add((word.location, Direction.down, 'Down'));
    }
    return MenuAnchor(
      builder: (context, controller, child) => InkWell(
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Text(
            character,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      menuChildren: [
        for (final (start, direction, label) in entries) ...[
          MenuItemButton(onPressed: null, child: Text(label)),
          for (final word
              in game.alternateWords[start]?[direction] ?? <String>[])
            _WordSelectMenuItem(
              location: start,
              direction: direction,
              word: word,
            ),
        ],
      ],
    );
  }
}

class _WordSelectMenuItem extends ConsumerWidget {
  const _WordSelectMenuItem({
    required this.location,
    required this.direction,
    required this.word,
  });
  final Location location;
  final Direction direction;
  final String word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(puzzleProvider).value;
    final enabled =
        game?.canSelectWord(
          location: location,
          word: word,
          direction: direction,
        ) ??
        false;
    final notifier = ref.read(puzzleProvider.notifier);
    return MenuItemButton(
      onPressed: enabled
          ? () => notifier.selectWord(
              location: location,
              word: word,
              direction: direction,
            )
          : null,
      child: Text(word.toUpperCase()),
    );
  }
}
