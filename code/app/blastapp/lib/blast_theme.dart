import 'package:flutter/material.dart';

class BlastTheme {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow, brightness: Brightness.light),
  );
    
  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple, brightness: Brightness.dark),
    );

}

