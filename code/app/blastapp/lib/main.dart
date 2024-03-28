import 'package:blastapp/ViewModel/app_view_model.dart';
import 'package:blastapp/ViewModel/eula_view_model.dart';
import 'package:blastapp/ViewModel/splash_view_model.dart';
import 'package:blastapp/main_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'win32register/win32register_stub.dart'
    if (dart.library.html) 'package:blastapp/win32register/win32register_web.dart'
    if (dart.library.io) 'package:blastapp/win32register/win32register_mobile.dart';
  
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppViewModel appViewModel = AppViewModel();

  var r = getWin32Register();
  await r.register('blastapp'); // register custom protocol for windows client only
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SplashViewModel(context)),
        ChangeNotifierProvider(create: (context) => EulaViewModel(context)),
      ],
      child: MaterialApp(
        title: "Blast App title",
        home: MainView(),
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: await appViewModel.getAppTheme(),
        /*   ThemeMode.system to follow system theme, 
            ThemeMode.light for light theme, 
            ThemeMode.dark for dark theme
          */
      ),
    ),
  );
}

