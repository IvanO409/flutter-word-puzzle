import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'crossword_widget.dart';

class CrosswordGeneratorApp extends ConsumerWidget {
  const CrosswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crossword Generator'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: const [_CrosswordGeneratorMenu()],
      ),
      body: const CrosswordWidget(),
    );
  }
}

class _CrosswordGeneratorMenu extends ConsumerWidget {
  const _CrosswordGeneratorMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSize = ref.watch(sizeProvider);

    return MenuAnchor(
      builder: (context, controller, child) {
        return IconButton(
          tooltip: 'Tamaño de cuadrícula',
          icon: const Icon(Icons.settings),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
      menuChildren: [
        for (final size in CrosswordSize.values)
          MenuItemButton(
            leadingIcon: currentSize == size
                ? const Icon(Icons.check)
                : const Icon(Icons.grid_on),
            onPressed: () {
              ref.read(sizeProvider.notifier).setSize(size);
            },
            child: Text(size.label),
          ),
      ],
    );
  }
}
