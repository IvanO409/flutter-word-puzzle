import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/model.dart';

void main() {
  group('Etapa 6 - Validaciones del crucigrama', () {
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

    test('No permite palabras duplicadas', () {
      final first = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      final result = first.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      );

      expect(result, isNull);
    });

    test('Rechaza palabras fuera de los límites', () {
      final result = base.addWord(
        location: Location.at(19, 2),
        word: 'cat',
        direction: Direction.across,
      );

      expect(result, isNull);
    });

    test('Rechaza coordenadas negativas', () {
      final result = base.addWord(
        location: Location.at(-1, 2),
        word: 'cat',
        direction: Direction.across,
      );

      expect(result, isNull);
    });

    test('Rechaza palabras desconectadas', () {
      final first = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      final result = first.addWord(
        location: Location.at(10, 7),
        word: 'dog',
        direction: Direction.across,
      );

      expect(result, isNull);
    });

    test('Rechaza palabras paralelas adyacentes', () {
      final first = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      final result = first.addWord(
        location: Location.at(1, 3),
        word: 'dog',
        direction: Direction.across,
      );

      expect(result, isNull);
    });

    test('Rechaza cruces con letras incompatibles', () {
      final first = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      final result = first.addWord(
        location: Location.at(2, 2),
        word: 'dog',
        direction: Direction.down,
      );

      expect(result, isNull);
    });

    test('No permite superposiciones en la misma dirección', () {
      final first = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      )!;

      final result = first.addWord(
        location: Location.at(2, 2),
        word: 'art',
        direction: Direction.across,
      );

      expect(result, isNull);
    });

    test('Acepta intersecciones válidas', () {
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

    test('Rechaza palabras de menos de tres letras', () {
      final result = base.addWord(
        location: Location.at(1, 2),
        word: 'at',
        direction: Direction.across,
      );

      expect(result, isNull);
    });

    test('Rechaza caracteres no permitidos', () {
      final result = base.addWord(
        location: Location.at(1, 2),
        word: 'c4t',
        direction: Direction.across,
      );

      expect(result, isNull);
    });

    test('El crucigrama vacío es válido', () {
      expect(base.valid, isTrue);
    });

    test('El crucigrama conserva el estado original', () {
      final result = base.addWord(
        location: Location.at(1, 2),
        word: 'cat',
        direction: Direction.across,
      );

      expect(base.words, isEmpty);
      expect(result!.words.length, 1);
    });
  });
}
