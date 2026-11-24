import 'dart:math';

import 'package:built_collection/built_collection.dart';

extension RandomElements<E> on BuiltSet<E> {
  E randomElement([Random? random]) {
    if (isEmpty) {
      throw StateError('No se puede seleccionar de un conjunto vacío');
    }

    final generator = random ?? Random();
    return elementAt(generator.nextInt(length));
  }
}
