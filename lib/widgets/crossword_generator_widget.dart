import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../model.dart';
import '../providers.dart';

class CrosswordGeneratorWidget extends ConsumerWidget {
  const CrosswordGeneratorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(sizeProvider);
    final queue = ref.watch(workQueueProvider).value;
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Generating crossword…'),
        ),
        const LinearProgressIndicator(),
        Expanded(
          child: TableView.builder(
            key: ValueKey(size),
            rowCount: size.height,
            columnCount: size.width,
            rowBuilder: (_) =>
                const TableSpan(extent: FixedTableSpanExtent(32)),
            columnBuilder: (_) =>
                const TableSpan(extent: FixedTableSpanExtent(32)),
            cellBuilder: (context, vicinity) {
              final location = Location.at(vicinity.column, vicinity.row);
              final occupied =
                  queue?.crossword.characters.containsKey(location) ?? false;
              return TableViewCell(
                child: AnimatedContainer(
                  duration: Durations.medium2,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: occupied
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 0.5,
                    ),
                  ),
                  child: Text(occupied ? '•' : ''),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
