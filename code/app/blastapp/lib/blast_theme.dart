import 'package:flutter/material.dart';

class BlastTheme {
  static ThemeData base = ThemeData(
    useMaterial3: true,
  );

  static ThemeData light = base.copyWith(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.light),
  );

  static ThemeData dark = base.copyWith(
    brightness: Brightness.dark,
    hoverColor: ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.dark).surfaceBrighr ,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.dark),
  );
}
