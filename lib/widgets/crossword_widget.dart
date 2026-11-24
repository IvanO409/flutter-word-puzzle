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
              // Observar el estado de la celda y la frontera de búsqueda.
              final queue = ref.watch(workQueueProvider).value;
              final character = queue?.crossword.characters[location];
              final explorationCell =
                  queue?.locationsToTry.containsKey(location) ?? false;
              final colors = Theme.of(context).colorScheme;
              return AnimatedContainer(
                duration: Durations.extralong1,
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: explorationCell
                      ? colors.primary
                      : character != null
                      ? colors.primaryContainer
                      : colors.surface,
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: Durations.extralong1,
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: explorationCell
                        ? colors.onPrimary
                        : colors.onSurface,
                  ),
                  child: Text(character?.character.toUpperCase() ?? ''),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
