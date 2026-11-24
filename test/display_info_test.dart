import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/model.dart';

void main() {
  test('DisplayInfo calcula métricas del WorkQueue', () {
    final crossword = Crossword.crossword(width: 20, height: 11).addWord(
      location: Location.at(0, 0),
      word: 'cat',
      direction: Direction.across,
    )!;
    final queue = WorkQueue.from(
      crossword: crossword,
      candidateWords: ['cat', 'art', 'dog'],
      startLocation: Location.at(0, 0),
    );
    final info = DisplayInfo.from(workQueue: queue);
    expect(info.wordsInGridCount, '1');
    expect(info.candidateWordsCount, '2');
    expect(info.gridFilledPercentage, '1.4%');
    expect(info.locationsToExploreCount, isNotEmpty);
  });

  test('DisplayInfo vacío tiene valores definidos', () {
    final info = DisplayInfo.empty;
    expect(info.wordsInGridCount, '0');
    expect(info.gridFilledPercentage, '0.0%');
  });
}
