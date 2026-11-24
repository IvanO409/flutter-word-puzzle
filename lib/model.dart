import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:characters/characters.dart';

part 'model.g.dart';

// =====================================================
// LOCATION
// =====================================================

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

// =====================================================
// DIRECTION
// =====================================================

enum Direction {
  across,
  down;

  @override
  String toString() => name;
}

// =====================================================
// CROSSWORD WORD
// =====================================================

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

// =====================================================
// CROSSWORD CHARACTER
// =====================================================

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

// =====================================================
// CROSSWORD
// =====================================================

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

  // ===================================================
  // VALIDACIONES DE LA ETAPA 6
  // ===================================================

  bool get valid {
    if (width <= 0 || height <= 0) return false;

    final usedWords = <String>{};
    final expected = <Location, String>{};
    final across = <Location, CrosswordWord>{};
    final down = <Location, CrosswordWord>{};

    for (final entry in words) {
      if (!usedWords.add(entry.word)) return false;

      if (entry.word.length < 3 || !RegExp(r'^[a-z]+$').hasMatch(entry.word)) {
        return false;
      }

      final letters = entry.word.characters.toList();

      for (var i = 0; i < letters.length; i++) {
        final location = entry.direction == Direction.across
            ? entry.location.rightOffset(i)
            : entry.location.downOffset(i);

        if (location.x < 0 ||
            location.y < 0 ||
            location.x >= width ||
            location.y >= height) {
          return false;
        }

        final existingLetter = expected[location];

        if (existingLetter != null && existingLetter != letters[i]) {
          return false;
        }

        expected[location] = letters[i];

        final directionMap = entry.direction == Direction.across
            ? across
            : down;

        if (directionMap.containsKey(location)) {
          return false;
        }

        directionMap[location] = entry;
      }
    }

    if (expected.length != characters.length) {
      return false;
    }

    for (final entry in expected.entries) {
      final location = entry.key;
      final cell = characters[location];

      if (cell == null || cell.character != entry.value) {
        return false;
      }

      if (cell.acrossWord != across[location] ||
          cell.downWord != down[location]) {
        return false;
      }

      final right = location.right;

      if (expected.containsKey(right)) {
        final first = across[location];
        final second = across[right];

        if (first == null || first != second) {
          return false;
        }
      }

      final below = location.down;

      if (expected.containsKey(below)) {
        final first = down[location];
        final second = down[below];

        if (first == null || first != second) {
          return false;
        }
      }
    }

    return true;
  }

  // ===================================================
  // AGREGAR PALABRAS
  // ===================================================

  Crossword? addWord({
    required Location location,
    required String word,
    required Direction direction,
  }) {
    if (word.length < 3 || !RegExp(r'^[a-z]+$').hasMatch(word)) {
      return null;
    }

    if (words.any((existing) => existing.word == word)) {
      return null;
    }

    var overlaps = 0;

    for (var i = 0; i < word.length; i++) {
      final position = direction == Direction.across
          ? location.rightOffset(i)
          : location.downOffset(i);

      if (position.x < 0 ||
          position.y < 0 ||
          position.x >= width ||
          position.y >= height) {
        return null;
      }

      final existing = characters[position];

      if (existing == null) continue;

      if (existing.character != word[i]) {
        return null;
      }

      if (direction == Direction.across && existing.acrossWord != null) {
        return null;
      }

      if (direction == Direction.down && existing.downWord != null) {
        return null;
      }

      overlaps++;
    }

    if (words.isNotEmpty && overlaps == 0) {
      return null;
    }

    final candidate = rebuild(
      (b) => b.words.add(
        CrosswordWord.word(
          word: word,
          location: location,
          direction: direction,
        ),
      ),
    );

    return candidate.valid ? candidate : null;
  }

  // ===================================================
  // CONSTRUIR EL MAPA DE CARACTERES
  // ===================================================

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

  // ===================================================
  // IMPRIMIR CRUCIGRAMA
  // ===================================================

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

// =====================================================
// WORK QUEUE - ETAPA 7
// =====================================================

abstract class WorkQueue implements Built<WorkQueue, WorkQueueBuilder> {
  Crossword get crossword;

  BuiltMap<Location, Direction> get locationsToTry;
  BuiltSet<Location> get badLocations;
  BuiltSet<String> get candidateWords;

  WorkQueue._();

  factory WorkQueue([void Function(WorkQueueBuilder) updates]) = _$WorkQueue;

  static Serializer<WorkQueue> get serializer => _$workQueueSerializer;

  bool get isCompleted => locationsToTry.isEmpty || candidateWords.isEmpty;

  // Construir una cola basada en el tablero actual.
  static WorkQueue from({
    required Crossword crossword,
    required Iterable<String> candidateWords,
    required Location startLocation,
  }) {
    return WorkQueue((b) {
      b.crossword.replace(crossword);

      final usedWords = crossword.words.map((entry) => entry.word).toSet();

      b.candidateWords.addAll(
        candidateWords.where(
          (word) =>
              word.length >= 3 &&
              word.length <=
                  (crossword.width > crossword.height
                      ? crossword.width
                      : crossword.height) &&
              !usedWords.contains(word),
        ),
      );

      // La primera palabra comienza en una semilla.
      if (crossword.words.isEmpty) {
        b.locationsToTry[startLocation] = Direction.across;
        return;
      }

      for (final entry in crossword.characters.entries) {
        final location = entry.key;
        final character = entry.value;

        // Una celda que ya contiene dos palabras
        // no necesita otro cruce.
        if (character.acrossWord != null && character.downWord != null) {
          continue;
        }

        final Direction direction;

        if (character.acrossWord != null) {
          direction = Direction.down;
        } else if (character.downWord != null) {
          direction = Direction.across;
        } else {
          continue;
        }

        // Impedir nuevas palabras cuando ya existen
        // vecinos que bloquearían el cruce.
        if (direction == Direction.across) {
          if (crossword.characters.containsKey(location.left) ||
              crossword.characters.containsKey(location.right)) {
            continue;
          }
        } else {
          if (crossword.characters.containsKey(location.up) ||
              crossword.characters.containsKey(location.down)) {
            continue;
          }
        }

        b.locationsToTry[location] = direction;
      }
    });
  }

  // Marcar una ubicación donde no se pudo
  // colocar ninguna palabra válida.
  WorkQueue remove(Location location) {
    return rebuild(
      (b) => b
        ..locationsToTry.remove(location)
        ..badLocations.add(location),
    );
  }

  // Actualizar la cola después de agregar una palabra.
  WorkQueue updateFrom(Crossword updatedCrossword) {
    final next = WorkQueue.from(
      crossword: updatedCrossword,
      candidateWords: candidateWords,
      startLocation: locationsToTry.isNotEmpty
          ? locationsToTry.keys.first
          : Location.at(0, 0),
    );

    return next.rebuild((b) {
      b.badLocations.addAll(badLocations);

      // No volver a probar ubicaciones fallidas.
      for (final location in badLocations) {
        b.locationsToTry.remove(location);
      }
    });
  }
}

// =====================================================
// SERIALIZADORES
// =====================================================

@SerializersFor([
  Location,
  Crossword,
  CrosswordWord,
  CrosswordCharacter,
  WorkQueue,
])
final Serializers serializers = _$serializers;
