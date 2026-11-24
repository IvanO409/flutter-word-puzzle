
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' hide MaterialApp, Scaffold, Text, Center, Colors, ThemeData, Brightness;

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Crossword Builder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        home: Scaffold(
          body: Center(
            child: Text(
              'Hello, World!',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    ),
  );
}
