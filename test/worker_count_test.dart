import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/providers.dart';

void main() {
  test('La etapa 10 usa cuatro trabajadores fijos', () {
    expect(backgroundWorkerCount, 4);
  });
}
