import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/choose_file_viewmodel.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  BuildContext? context;

  bool isInitializing = true;
  bool isLoading = false;
  Future<ThemeMode> get currentThemeMode => SettingService().appTheme;

  SplashViewModel();

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
    return context!.router.push(const EulaRoute());
  }

  goToChooseStorage() async {
    CurrentFileService().reset();

    final myContext = context!;
    
    var isStorageSelected = await myContext.router.push(const ChooseStorageRoute());
    if (isStorageSelected != true) {
        return;
      }
    
    if (!myContext.mounted) return;
    FileSelectionResult? isFileSelected = await myContext.router.push<FileSelectionResult>(const ChooseFileRoute());
    if (isFileSelected != FileSelectionResult.newFile && isFileSelected != FileSelectionResult.existingFile) {
      return;
    }

    if (isFileSelected == FileSelectionResult.newFile) {
      if (!myContext.mounted) return;
      var isFileCreated = await myContext.router.push(const CreatePasswordRoute());

      if (isFileCreated != true) {
        return;
      }
    }
    else if (isFileSelected == FileSelectionResult.existingFile) {
      if (!myContext.mounted) return;
      var isFileDecrypted = await myContext.router.push(const TypePasswordRoute());
      if (isFileDecrypted != true) {
        return;
      }
    }

    _addCurrentFileToRecent();

    if (!myContext.mounted) return;
    await myContext.router.push(const CardFileInfoRoute());

    if (!myContext.mounted) return;
    await myContext.router.push(const CardsBrowserRoute());
  }

  goToRecentFile(BlastFile file) async {
    isLoading = true;
    notifyListeners();

    final myContext = context!;

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
    
    if (!myContext.mounted) return;
    var isFileDecrypted = await myContext.router.push(const TypePasswordRoute());
    if (isFileDecrypted == true) {
      _addCurrentFileToRecent();

      if (!myContext.mounted) return;
      myContext.router.push(const CardsBrowserRoute());
    }
  }

  void _addCurrentFileToRecent() {
    final file = CurrentFileService().currentFileInfo;
    if (file != null) {
      SettingService().addRecentFile(file);
    }
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

  void openMostRecentFile() async {
    final recents = await SettingService().getRecentFiles();
    if (recents.isNotEmpty) {
      await goToRecentFile(recents.first);
    }
  }

  Future<bool> isInitializingAsync() async {
    return isInitializing;
  }
}
