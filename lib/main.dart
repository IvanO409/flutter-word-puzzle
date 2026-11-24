import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/crossword_puzzle_app.dart';

void main() {
  runApp(const ProviderScope(child: CrosswordPuzzleRoot()));
}

class CrosswordPuzzleRoot extends StatelessWidget {
  const CrosswordPuzzleRoot({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Crossword Puzzle',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blueGrey),
    home: const CrosswordPuzzleApp(),
  );
}
