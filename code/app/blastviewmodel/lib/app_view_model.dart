import 'package:flutter/material.dart';
import 'package:blastmodel/settings_service.dart';

class AppViewModel {

  AppViewModel() {
    // init things inside this
  }

  Future<ThemeMode> getAppTheme () async {
    switch (await SettingService().appTheme)
    {
      case BlaseAppTheme.auto:
        return ThemeMode.system;
      case BlaseAppTheme.light:
        return ThemeMode.light;
      case BlaseAppTheme.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;}
  }
}
