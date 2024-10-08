import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  BuildContext context;

  bool isLoading = false;
  Future<ThemeMode> get currentThemeMode => SettingService().appTheme;

  SplashViewModel(this.context);

  Future<bool> eulaAccepted() async {
    return SettingService().eulaAccepted;
  }

  Future<bool> eulaNotAccepted() async {
    return !await SettingService().eulaAccepted;
  }

  Future<List<BlastFile>> recentFiles() async {
    return SettingService().getRecentFiles();
  }

  Future<Cloud> getCloudStorageById(String id) async {
    return await SettingService().getCloudStorageById(id);
  }

  showEula() async {
    return context.router.push(const EulaRoute());
  }

  goToChooseStorage() async {
    return context.router.push(const ChooseStorageRoute());
  }

  goToRecentFile(BlastFile file) async {
    isLoading = true;
    notifyListeners();

    try {
      CurrentFileService().reset();
      CurrentFileService().cloud = await SettingService().getCloudStorageById(file.cloudId);
      CurrentFileService().currentFileInfo = file;

      CurrentFileService().currentFileEncrypted =
          await CurrentFileService().cloud!.getFile(CurrentFileService().currentFileInfo!.fileUrl);
    } finally {
      isLoading = false;
      notifyListeners();
    }

    if (!context.mounted) return;
    return context.router.push(const TypePasswordRoute());
  }

  void refresh() {
    notifyListeners();
  }

  removeFromRecent(BlastFile file) async {
    SettingService().recentFiles.list.remove(file);

    SettingService().setRecentFiles(SettingService().recentFiles.list);
  }

  Future<ThemeMode> toggleLightDarkMode() async {
    var themeSwitcher = {
      ThemeMode.system: ThemeMode.light,
      ThemeMode.light: ThemeMode.dark,
      ThemeMode.dark: ThemeMode.system,
    };

    var currentTheme = await SettingService().appTheme;
    SettingService().setAppTheme(themeSwitcher[currentTheme] ?? ThemeMode.system);

    return SettingService().appTheme;
  }
}
