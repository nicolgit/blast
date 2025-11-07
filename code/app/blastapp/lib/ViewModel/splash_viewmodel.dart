import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/choose_file_viewmodel.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastapp/helpers/biometric_helper.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:humanizer/humanizer.dart';

class SplashViewModel extends ChangeNotifier {
  // SplashViewModel singleton implementation begin
  SplashViewModel._privateConstructor();
  static final SplashViewModel _instance = SplashViewModel._privateConstructor();
  factory SplashViewModel() {
    return _instance;
  }
  // singleton end

  BuildContext? context;

  bool isInitializing = true;
  bool isLoading = false;
  Future<ThemeMode> get currentThemeMode => SettingService().appTheme;

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

  Future<Object?> showEula() async {
    return await context!.router.push(const EulaRoute());
  }

  Future<void> goToChooseStorage() async {
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
    } else if (isFileSelected == FileSelectionResult.existingFile) {
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

  Future<void> goToRecentFile(BlastFile file) async {
    isLoading = true;
    notifyListeners();

    final myContext = context!;

    try {
      CurrentFileService().reset();
      CurrentFileService().cloud = await SettingService().getCloudStorageById(file.cloudId);
      CurrentFileService().currentFileInfo = file;

      if (CurrentFileService().cloud!.hasCachedCredentials) {
        await BiometricHelper.readData();
      }

      final myFile = await CurrentFileService().cloud!.getFile(CurrentFileService().currentFileInfo!.fileUrl);
      CurrentFileService().currentFileInfo?.lastModified = myFile.lastModified;
      CurrentFileService().currentFileEncrypted = myFile.data;

      isLoading = false;
      notifyListeners();

      if (!myContext.mounted) return;
      var isFileDecrypted = await myContext.router.push(const TypePasswordRoute());
      if (isFileDecrypted == true) {
        _addCurrentFileToRecent();

        if (!myContext.mounted) return;
        myContext.router.push(const CardsBrowserRoute());
      }
    } catch (e) {
      SettingService().setBiometricAuthEnabled(false);
      CurrentFileService().cloud!.cachedCredentials = null;
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
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

  Future<void> removeFromRecent(BlastFile file) async {
    CurrentFileService().cloud = await SettingService().getCloudStorageById(file.cloudId);
    await CurrentFileService().cloud!.logOut();

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

  Future<bool> closeAll() async {
    // check if the current page is already the splash screen
    if (context?.router.current.name == SplashRoute.name) {
      return false;
    }

    final durationInt = await SettingService().autoLogoutAfter;
    final duration = Duration(minutes: durationInt);

    // navigate back up to the splash screen
    context?.router.popUntil((route) => route.settings.name == SplashRoute.name);

    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Session timeout'),
          content: Text(
              'You have been inactive for the last ${duration.toApproximateTime(isRelativeToNow: false)} . For security reason the session has been closed.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return true;
  }
}
