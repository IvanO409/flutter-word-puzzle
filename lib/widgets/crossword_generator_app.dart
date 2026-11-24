import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'crossword_info_widget.dart';
import 'crossword_widget.dart';

class CrosswordGeneratorApp extends ConsumerWidget {
  const CrosswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showInfo = ref.watch(showDisplayInfoProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crossword Generator'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: const [_CrosswordGeneratorMenu()],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: CrosswordWidget()),
          if (showInfo)
            const Positioned(
              right: 12,
              bottom: 12,
              child: CrosswordInfoWidget(),
            ),
        ],
      ),
    );
  }
}

class _CrosswordGeneratorMenu extends ConsumerWidget {
  const _CrosswordGeneratorMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSize = ref.watch(sizeProvider);
    final showInfo = ref.watch(showDisplayInfoProvider);
    return MenuAnchor(
      builder: (context, controller, child) => IconButton(
        tooltip: 'Settings',
        icon: const Icon(Icons.settings),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        for (final size in CrosswordSize.values)
          MenuItemButton(
            leadingIcon: Icon(
              currentSize == size ? Icons.check : Icons.grid_on,
            ),
            onPressed: () => ref.read(sizeProvider.notifier).setSize(size),
            child: Text(size.label),
          ),
        const Divider(),
        MenuItemButton(
          leadingIcon: Icon(
            showInfo ? Icons.check_box : Icons.check_box_outline_blank,
          ),
          onPressed: () => ref.read(showDisplayInfoProvider.notifier).toggle(),
          child: const Text('Display Info'),
        ),
      ],
    );
  }
}
