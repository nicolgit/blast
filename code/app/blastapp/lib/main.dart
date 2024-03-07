import 'dart:io';

import 'package:blastapp/ViewModel/app_view_model.dart';
import 'package:blastapp/ViewModel/eula_view_model.dart';
import 'package:blastapp/ViewModel/splash_view_model.dart';
import 'package:blastapp/main_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:win32_registry/win32_registry.dart'; // for windows registry access

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppViewModel appViewModel = AppViewModel();

  if (Platform.isWindows) {
    await register('blastapp'); // register custom protocol for windows
  }

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

Future<void> register(String scheme) async {
  String appPath = Platform.resolvedExecutable;

  String protocolRegKey = 'Software\\Classes\\$scheme';
  RegistryValue protocolRegValue = const RegistryValue(
    'URL Protocol',
    RegistryValueType.string,
    '',
  );
  String protocolCmdRegKey = 'shell\\open\\command';
  RegistryValue protocolCmdRegValue = RegistryValue(
    '',
    RegistryValueType.string,
    '"$appPath" "%1"',
  );

  final regKey = Registry.currentUser.createKey(protocolRegKey);
  regKey.createValue(protocolRegValue);
  regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
}
