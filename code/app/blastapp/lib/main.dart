import 'package:blastapp/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:blastviewmodel/app_view_model.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  final AppViewModel appViewModel = AppViewModel();

  runApp(MaterialApp(
    title: "Blast App title",
    home: const SplashView(),
    theme: ThemeData.light(useMaterial3: true),
    darkTheme: ThemeData.dark(useMaterial3: true),
    themeMode: await appViewModel.getAppTheme(),
    /*   ThemeMode.system to follow system theme, 
         ThemeMode.light for light theme, 
         ThemeMode.dark for dark theme
      */
  ));

  
}
