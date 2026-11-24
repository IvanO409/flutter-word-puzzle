import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../model.dart';
import '../providers.dart';

class CrosswordWidget extends ConsumerWidget {
  const CrosswordWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(sizeProvider);

    return TableView.builder(
      key: ValueKey(size),
      rowCount: size.height,
      columnCount: size.width,
      rowBuilder: (row) => const TableSpan(extent: FixedTableSpanExtent(32)),
      columnBuilder: (column) =>
          const TableSpan(extent: FixedTableSpanExtent(32)),
      cellBuilder: (context, vicinity) {
        final location = Location.at(vicinity.column, vicinity.row);

        return TableViewCell(
          child: Consumer(
            builder: (context, ref, child) {
              final character = ref.watch(
                crosswordProvider.select(
                  (crosswordAsync) => crosswordAsync.when(
                    data: (crossword) => crossword.characters[location],
                    error: (error, stackTrace) => null,
                    loading: () => null,
                  ),
                ),
              );

              final hasLetter = character != null;

              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: hasLetter
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
                child: hasLetter
                    ? Text(
                        character.character.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}
