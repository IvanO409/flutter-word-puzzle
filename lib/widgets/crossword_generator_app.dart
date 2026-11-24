import 'package:flutter/material.dart';

import 'crossword_puzzle_app.dart';

@Deprecated('Use CrosswordPuzzleApp')
class CrosswordGeneratorApp extends StatelessWidget {
  const CrosswordGeneratorApp({super.key});
  @override
  Widget build(BuildContext context) => const CrosswordPuzzleApp();
}
