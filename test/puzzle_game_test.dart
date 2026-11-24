import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/model.dart';

void main() {
  test('Permite palabras sin superposición al jugar', () {
    final board = Crossword.crossword(width: 20, height: 11).addWord(
      location: Location.at(0, 0),
      word: 'cat',
      direction: Direction.across,
    )!;
    final second = board.addWord(
      location: Location.at(10, 5),
      word: 'dog',
      direction: Direction.across,
      requireOverlap: false,
    );
    expect(second, isNotNull);
  });

  test('Alternativas coinciden en longitud y se puede ganar', () {
    final answer = Crossword.crossword(width: 20, height: 11).addWord(
      location: Location.at(1, 2),
      word: 'cat',
      direction: Direction.across,
    )!;
    final game = CrosswordPuzzleGame.from(
      crossword: answer,
      candidateWords: BuiltSet<String>([
        'dog',
        'hat',
        'rat',
        'bat',
        'sat',
        'hello',
      ]),
    );
    final choices = game.alternateWords[Location.at(1, 2)]![Direction.across]!;
    expect(choices.length, 5);
    expect(choices.every((word) => word.length == 3), isTrue);
    expect(game.solved, isFalse);
    final solved = game.selectWord(
      location: Location.at(1, 2),
      word: 'cat',
      direction: Direction.across,
    );
    expect(solved, isNotNull);
    expect(solved!.solved, isTrue);
  });

  test('No permite seleccionar opciones que no están en el menú', () {
    final answer = Crossword.crossword(width: 20, height: 11).addWord(
      location: Location.at(1, 2),
      word: 'cat',
      direction: Direction.across,
    )!;
    final game = CrosswordPuzzleGame.from(
      crossword: answer,
      candidateWords: BuiltSet<String>(['dog']),
    );
    expect(
      game.canSelectWord(
        location: Location.at(1, 2),
        word: 'unknown',
        direction: Direction.across,
      ),
      isFalse,
    );
  });
}
