import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generate_crossword/providers.dart';

void main() {
  test('El número predeterminado de trabajadores es cuatro', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(workerCountProvider), BackgroundWorkers.four);
  });

  test('Permite cambiar entre uno y 128 trabajadores', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(workerCountProvider.notifier)
        .setCount(BackgroundWorkers.one);
    expect(container.read(workerCountProvider).count, 1);
    container
        .read(workerCountProvider.notifier)
        .setCount(BackgroundWorkers.oneTwentyEight);
    expect(container.read(workerCountProvider).count, 128);
  });
}
