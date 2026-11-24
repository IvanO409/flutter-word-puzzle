import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../utils.dart';
import 'ticker_builder.dart';

class CrosswordInfoWidget extends ConsumerWidget {
  const CrosswordInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(displayInfoProvider);
    final start = ref.watch(startTimeProvider);
    final end = ref.watch(endTimeProvider);
    final expected = ref.watch(expectedRemainingTimeProvider);
    final workers = ref.watch(workerCountProvider);
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 6,
      color: colors.surfaceContainerHigh,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Generation statistics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Hide statistics',
                    onPressed: () => ref
                        .read(showDisplayInfoProvider.notifier)
                        .setVisible(false),
                  ),
                ],
              ),
              const Divider(),
              _StatLine(label: 'Words in grid', value: info.wordsInGridCount),
              _StatLine(
                label: 'Candidate words',
                value: info.candidateWordsCount,
              ),
              _StatLine(
                label: 'Locations to explore',
                value: info.locationsToExploreCount,
              ),
              _StatLine(
                label: 'Known bad locations',
                value: info.knownBadLocationsCount,
              ),
              _StatLine(label: 'Grid filled', value: info.gridFilledPercentage),
              _StatLine(label: 'Max worker count', value: '${workers.count}'),
              switch ((start, end)) {
                (null, _) => const _StatLine(
                  label: 'Time elapsed',
                  value: 'Not started yet',
                ),
                (DateTime started, null) => TickerBuilder(
                  builder: (context) => _StatLine(
                    label: 'Time elapsed',
                    value: DateTime.now().difference(started).formatted,
                  ),
                ),
                (DateTime started, DateTime finished) => _StatLine(
                  label: 'Completed in',
                  value: finished.difference(started).formatted,
                ),
              },
              if (start != null && end == null)
                _StatLine(
                  label: 'Estimated remaining',
                  value: expected == Duration.zero
                      ? 'Calculating…'
                      : expected.formatted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
