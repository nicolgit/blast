import 'package:flutter/material.dart';
import 'package:blastmodel/settings_service.dart';

class AppViewModel {
  AppViewModel() {
    // init things inside this
  }

  Future<ThemeMode> getAppTheme() async {
    return await SettingService().appTheme;
  }
}
