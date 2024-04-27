import 'package:flutter/material.dart';

class BlastTheme {
  static ThemeData base = ThemeData(
    useMaterial3: true,
  );

  static ThemeData light = base.copyWith(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow, brightness: Brightness.light),
  );

  static ThemeData dark = base.copyWith(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow, brightness: Brightness.dark),
  );
}
