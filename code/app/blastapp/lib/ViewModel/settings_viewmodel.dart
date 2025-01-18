import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

class ThemeTuple {
  final String themeName;
  final ThemeMode themeMode;
  final IconData icon;

  ThemeTuple(this.themeName, this.themeMode, this.icon);
}

class SettingsViewModel extends ChangeNotifier {
  final BuildContext context;
  final SettingService settingService = SettingService();
  
  Future<ThemeMode> get themeMode async {
    return await settingService.appTheme;
  }
  Future<void> setThemeMode(ThemeMode value) async {
    settingService.setAppTheme(value);
    notifyListeners();
  }

  SettingsViewModel(this.context);

  void closeCommand() {
    context.router.maybePop();
  }

 List<ThemeTuple>  getThemeSelectorItems() {
    return [
      ThemeTuple("  System  ", ThemeMode.system, Icons.auto_awesome),
      ThemeTuple("  Light  ", ThemeMode.light, Icons.light_mode),
      ThemeTuple("  Dark  ", ThemeMode.dark , Icons.dark_mode ),
    ];
  }
}
