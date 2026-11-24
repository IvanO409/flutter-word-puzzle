import 'package:flutter_test/flutter_test.dart';

import 'package:generate_crossword/model.dart';
import 'package:generate_crossword/utils.dart';

void main() {
  group('Etapa 6 - Restricciones', () {
    late Crossword base;

    setUp(() {
      base = Crossword.crossword(width: 20, height: 11);
    });

    test('Acepta la primera palabra', () {
      final result = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      );

      expect(result, isNotNull);
      expect(result!.valid, isTrue);
    });

    test('Rechaza palabras duplicadas', () {
      final first = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      expect(
        first.addWord(
          location: Location.at(1, 2),
          word: 'cat',
          direction: Direction.across,
        ),
        isNull,
      );
    });

    test('Rechaza palabras fuera del tablero', () {
      expect(
        base.addWord(
          location: Location.at(19, 2),
          word: 'cat',
          direction: Direction.across,
        ),
        isNull,
      );
    });

    test('Rechaza coordenadas negativas', () {
      expect(
        base.addWord(
          location: Location.at(-1, 2),
          word: 'cat',
          direction: Direction.across,
        ),
        isNull,
      );
    });

    test('Rechaza palabras desconectadas', () {
      final first = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      expect(
        first.addWord(
          location: Location.at(10, 7),
          word: 'dog',
          direction: Direction.across,
        ),
        isNull,
      );
    });

    test('Rechaza palabras paralelas adyacentes', () {
      final first = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      expect(
        first.addWord(
          location: Location.at(1, 3),
          word: 'dog',
          direction: Direction.across,
        ),
        isNull,
      );
    });

    test('Rechaza cruces con letras incompatibles', () {
      final first = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      expect(
        first.addWord(
          location: Location.at(2, 2),
          word: 'dog',
          direction: Direction.down,
        ),
        isNull,
      );
    });

    test('Rechaza superposición en la misma dirección', () {
      final first = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      expect(
        first.addWord(
          location: Location.at(2, 2),
          word: 'art',
          direction: Direction.across,
        ),
        isNull,
      );
    });

    test('Acepta una intersección válida', () {
      final first = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      final result = first.addWord(
        location: Location.at(2, 2),
        word: 'art',
        direction: Direction.down,
      );

      expect(result, isNotNull);
      expect(result!.valid, isTrue);
      expect(result.words.length, 2);

      final intersection = result.characters[Location.at(2, 2)];

      expect(intersection?.character, 'a');
      expect(intersection?.acrossWord, isNotNull);
      expect(intersection?.downWord, isNotNull);
    });

    test('Rechaza palabras demasiado cortas', () {
      expect(
        base.addWord(
          location: Location.at(1, 2),
          word: 'at',
          direction: Direction.across,
        ),
        isNull,
      );
    });

    test('Rechaza caracteres inválidos', () {
      expect(
        base.addWord(
          location: Location.at(1, 2),
          word: 'c4t',
          direction: Direction.across,
        ),
        isNull,
      );
    });

    test('Crucigrama vacío válido', () {
      expect(base.valid, isTrue);
    });

    test('Conserva estado inmutable', () {
      final result = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      );

      expect(base.words, isEmpty);
      expect(result!.words.length, 1);
    });
  });

  group('Etapa 7 - WorkQueue', () {
    late Crossword emptyCrossword;

    setUp(() {
      emptyCrossword = Crossword.crossword(width: 20, height: 11);
    });

    test('Inicializa la cola en la semilla', () {
      final queue = WorkQueue.from(
        crossword: emptyCrossword,
        candidateWords: ['cat', 'art', 'dog'],
        startLocation: Location.at(0, 0),
      );

      expect(queue.locationsToTry[Location.at(0, 0)], Direction.across);

      expect(queue.isCompleted, isFalse);
    });

    test('Descarta palabras usadas', () {
      final crossword = emptyCrossword.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      final queue = WorkQueue.from(
        crossword: crossword,
        candidateWords: ['cat', 'art', 'dog'],
        startLocation: Location.at(0, 0),
      );

      expect(queue.candidateWords.contains('cat'), isFalse);
      expect(queue.candidateWords.contains('art'), isTrue);
    });

    test('Encuentra intersecciones disponibles', () {
      final crossword = emptyCrossword.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      final queue = WorkQueue.from(
        crossword: crossword,
        candidateWords: ['art', 'dog'],
        startLocation: Location.at(0, 0),
      );

      expect(queue.locationsToTry[Location.at(2, 2)], Direction.down);
    });

    test('Marca ubicaciones fallidas', () {
      final queue = WorkQueue.from(
        crossword: emptyCrossword,
        candidateWords: ['cat'],
        startLocation: Location.at(0, 0),
      );

      final updated = queue.remove(Location.at(0, 0));

      expect(updated.badLocations.contains(Location.at(0, 0)), isTrue);

      expect(updated.locationsToTry, isEmpty);
      expect(updated.isCompleted, isTrue);
    });

    test('Actualiza la cola después de agregar palabra', () {
      final queue = WorkQueue.from(
        crossword: emptyCrossword,
        candidateWords: ['cat', 'art'],
        startLocation: Location.at(0, 0),
      );

      final crossword = emptyCrossword.addWord(
        location: Location.at(0, 0),
        word: 'cat',
        direction: Direction.across,
      )!;

      final updated = queue.updateFrom(crossword);

      expect(updated.crossword.words.length, 1);
      expect(updated.candidateWords.contains('cat'), isFalse);
      expect(updated.locationsToTry.isNotEmpty, isTrue);
    });

    test('Conserva ubicaciones malas conocidas', () {
      final crossword = emptyCrossword.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      final queue = WorkQueue.from(
        crossword: crossword,
        candidateWords: ['art', 'dog'],
        startLocation: Location.at(0, 0),
      );

      final bad = Location.at(1, 2);
      final removed = queue.remove(bad);

      final updated = removed.updateFrom(crossword);

      expect(updated.badLocations.contains(bad), isTrue);
      expect(updated.locationsToTry.containsKey(bad), isFalse);
    });

    test('Finaliza sin palabras candidatas', () {
      final queue = WorkQueue.from(
        crossword: emptyCrossword,
        candidateWords: [],
        startLocation: Location.at(0, 0),
      );

      expect(queue.isCompleted, isTrue);
    });
  });

  group('Etapa 7 - DurationFormat', () {
    test('Formatea segundos', () {
      expect(const Duration(seconds: 8).formatted, '8s');
    });

    test('Formatea minutos', () {
      expect(const Duration(minutes: 2, seconds: 5).formatted, '2:05');
    });

    test('Formatea horas', () {
      expect(
        const Duration(hours: 1, minutes: 2, seconds: 3).formatted,
        '1:02:03',
      );
    });
  });
}
