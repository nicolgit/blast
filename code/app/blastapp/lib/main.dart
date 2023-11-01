import 'package:blastapp/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:viewmodelpackage/viewmodelpackage.dart';

void main() {
  // test package references
  final viewModelCalculator = ViewModelCalculator();
  viewModelCalculator.addOne(12);

  runApp(MaterialApp(
    title: "Blast App title",
    home: const SplashView(),
    theme: ThemeData.light(useMaterial3: true),
    darkTheme: ThemeData.dark(useMaterial3: true),
    themeMode: ThemeMode.system,
    /* ThemeMode.system to follow system theme, 
         ThemeMode.light for light theme, 
         ThemeMode.dark for dark theme
      */
    
  ));
}
