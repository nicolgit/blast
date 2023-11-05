import 'package:blastapp/ViewModel/app_view_model.dart';
import 'package:blastapp/main_view.dart';
import 'package:flutter/material.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  final AppViewModel appViewModel = AppViewModel();
  
  runApp(MaterialApp(
    title: "Blast App title",
    home: MainView(),
    theme: ThemeData.light(useMaterial3: true),
    darkTheme: ThemeData.dark(useMaterial3: true),
    themeMode: await appViewModel.getAppTheme(),
    /*   ThemeMode.system to follow system theme, 
         ThemeMode.light for light theme, 
         ThemeMode.dark for dark theme
      */
  ));

  
}
