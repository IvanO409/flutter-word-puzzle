import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:characters/characters.dart';

part 'model.g.dart';

abstract class Location implements Built<Location, LocationBuilder> {
  int get x;
  int get y;

  Location._();

  factory Location([void Function(LocationBuilder) updates]) = _$Location;

  factory Location.at(int x, int y) => Location(
    (b) => b
      ..x = x
      ..y = y,
  );

  Location get left => leftOffset(1);
  Location get right => rightOffset(1);
  Location get up => upOffset(1);
  Location get down => downOffset(1);

  Location leftOffset(int offset) => Location.at(x - offset, y);
  Location rightOffset(int offset) => Location.at(x + offset, y);
  Location upOffset(int offset) => Location.at(x, y - offset);
  Location downOffset(int offset) => Location.at(x, y + offset);

  String prettyPrint() => '($x, $y)';

  static Serializer<Location> get serializer => _$locationSerializer;
}

enum Direction {
  across,
  down;

  @override
  String toString() => name;
}

abstract class CrosswordWord
    implements Built<CrosswordWord, CrosswordWordBuilder> {
  String get word;
  Location get location;
  Direction get direction;

  CrosswordWord._();

  factory CrosswordWord([void Function(CrosswordWordBuilder) updates]) =
      _$CrosswordWord;

  factory CrosswordWord.word({
    required String word,
    required Location location,
    required Direction direction,
  }) => CrosswordWord(
    (b) => b
      ..word = word
      ..location.replace(location)
      ..direction = direction,
  );

  static int locationComparator(CrosswordWord a, CrosswordWord b) {
    final byY = a.location.y.compareTo(b.location.y);
    if (byY != 0) return byY;
    return a.location.x.compareTo(b.location.x);
  }

  static Serializer<CrosswordWord> get serializer => _$crosswordWordSerializer;
}

abstract class CrosswordCharacter
    implements Built<CrosswordCharacter, CrosswordCharacterBuilder> {
  String get character;
  CrosswordWord? get acrossWord;
  CrosswordWord? get downWord;

  CrosswordCharacter._();

  factory CrosswordCharacter([
    void Function(CrosswordCharacterBuilder) updates,
  ]) = _$CrosswordCharacter;

  factory CrosswordCharacter.character({
    required String character,
    CrosswordWord? acrossWord,
    CrosswordWord? downWord,
  }) => CrosswordCharacter((b) {
    b.character = character;
    if (acrossWord != null) {
      b.acrossWord.replace(acrossWord);
    }
    if (downWord != null) {
      b.downWord.replace(downWord);
    }
  });

  static Serializer<CrosswordCharacter> get serializer =>
      _$crosswordCharacterSerializer;
}

abstract class Crossword implements Built<Crossword, CrosswordBuilder> {
  int get width;
  int get height;

  BuiltList<CrosswordWord> get words;
  BuiltMap<Location, CrosswordCharacter> get characters;

  Crossword._();

  factory Crossword([void Function(CrosswordBuilder) updates]) = _$Crossword;

  factory Crossword.crossword({required int width, required int height}) =>
      Crossword(
        (b) => b
          ..width = width
          ..height = height,
      );

  Crossword addWord({
    required Location location,
    required String word,
    required Direction direction,
  }) {
    final newWord = CrosswordWord.word(
      word: word,
      location: location,
      direction: direction,
    );

    return rebuild((b) => b.words.add(newWord));
  }

  @BuiltValueHook(finalizeBuilder: true)
  static void _fillCharacters(CrosswordBuilder b) {
    final characters = <Location, CrosswordCharacter>{};

    for (final word in b.words.build()) {
      for (final (index, letter) in word.word.characters.indexed) {
        final location = switch (word.direction) {
          Direction.across => word.location.rightOffset(index),
          Direction.down => word.location.downOffset(index),
        };

        final existing = characters[location];

        if (existing == null) {
          characters[location] = CrosswordCharacter.character(
            character: letter,
            acrossWord: word.direction == Direction.across ? word : null,
            downWord: word.direction == Direction.down ? word : null,
          );
        } else {
          characters[location] = existing.rebuild((cell) {
            cell.character = letter;

            if (word.direction == Direction.across) {
              cell.acrossWord.replace(word);
            } else {
              cell.downWord.replace(word);
            }
          });
        }
      }
    }

    b.characters
      ..clear()
      ..addAll(characters);
  }

  String prettyPrintCrossword() {
    final buffer = StringBuffer();

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        buffer.write(characters[Location.at(x, y)]?.character ?? '.');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  static Serializer<Crossword> get serializer => _$crosswordSerializer;
}

@SerializersFor([Location, Crossword, CrosswordWord, CrosswordCharacter])
final Serializers serializers = _$serializers;
