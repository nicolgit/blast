import 'dart:io';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/lorem_cloud.dart';
import 'package:blastmodel/Cloud/filesystem_cloud.dart';
import 'package:blastmodel/Cloud/onedrive_cloud.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/blastfilelist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum QrCodeViewStyle { text, qrcode, barcode }

class SettingService {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  BlastFileList recentFiles = BlastFileList();
  List<Cloud> cloudStorages = [];

  static final SettingService _instance = SettingService._internal();

  factory SettingService() {
    return _instance;
  }

  SettingService._internal() {
    // init cloud storages list
    cloudStorages.add(OneDriveCloud());
    if (kIsWeb) {
      // nothing to do
    } else if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      cloudStorages.add(FileSystemCloud());
    }
    cloudStorages.add(LoremCloud());
  }

  // Add your methods and properties here
  Future<bool> get eulaAccepted async {
    var prefs = await _prefs;
    return prefs.getBool('eulaAccepted') ?? false;
  }

  Future<void> setEulaAccepted(bool value) async {
    var prefs = await _prefs;
    await prefs.setBool('eulaAccepted', value);
  }

  Future<bool> get rememberLastQrCodeView async {
    var prefs = await _prefs;
    return prefs.getBool('rememberLastQr') ?? true;
  }

  Future<void> setRememberLastQrCodeView(bool value) async {
    var prefs = await _prefs;
    await prefs.setBool('rememberLastQr', value);
  }

  Future<QrCodeViewStyle> get defaultQrCodeView async {
    var prefs = await _prefs;
    return QrCodeViewStyle.values[prefs.getInt('defaultQr') ?? QrCodeViewStyle.qrcode.index];
  }

  Future<void> setDefaultQrCodeView(QrCodeViewStyle value) async {
    var prefs = await _prefs;
    await prefs.setInt('defaultQr', value.index);
  }

  Future<ThemeMode> get appTheme async {
    var prefs = await _prefs;
    return ThemeMode.values[prefs.getInt('appTheme') ?? ThemeMode.system.index];
  }

  Future<void> setAppTheme(ThemeMode value) async {
    var prefs = await _prefs;
    await prefs.setInt('appTheme', value.index);
  }

  Future<int> get autoLogoutAfter async {
    var prefs = await _prefs;
    return prefs.getInt('appTimeout') ?? 5;
  }

  Future<void> setAutoLogoutAfter(int value) async {
    var prefs = await _prefs;
    await prefs.setInt('appTimeout', value);
  }

  Future<bool> get biometricAuthEnabled async {
    var prefs = await _prefs;
    return prefs.getBool('biometricAuthEnabled') ?? false;
  }

  Future<void> setBiometricAuthEnabled(bool value) async {
    var prefs = await _prefs;
    await prefs.setBool('biometricAuthEnabled', value);
  }

  Future<bool> get askForBiometricAuth async {
    var prefs = await _prefs;
    return prefs.getBool('askForBiometricAuth') ?? true;
  }

  Future<void> setAskForBiometricAuth(bool value) async {
    var prefs = await _prefs;
    await prefs.setBool('askForBiometricAuth', value);
  }

  Future<bool> get autoSave async {
    var prefs = await _prefs;
    return prefs.getBool('autoSave') ?? true;
  }

  Future<void> setAutoSave(bool value) async {
    var prefs = await _prefs;
    await prefs.setBool('autoSave', value);
  }

  Future<List<BlastFile>> getRecentFiles() async {
    if (recentFiles.list.isNotEmpty) {
      return recentFiles.list;
    } else {
      var prefs = await _prefs;
      var jsonRecent = prefs.getString('recentFiles') ?? '[]';

      try {
        recentFiles = BlastFileList.fromJson(jsonDecode(jsonRecent));
      } catch (e) {
        recentFiles = BlastFileList();
      }

      recentFiles.list = recentFiles.list.where((file) {
        var cloud = cloudStorages.any((element) => element.id == file.cloudId);
        return cloud;
      }).toList();

      return recentFiles.list;
    }
  }

  Future<void> setRecentFiles(List<BlastFile> value) async {
    recentFiles.list = value;

    _saveRecentFiles();
  }

  Future<List<Cloud>> getCloudStoragelist() {
    return Future.value(cloudStorages);
  }

  Future<Cloud> getCloudStorageById(String id) async {
    return cloudStorages.firstWhere((element) => element.id == id);
  }

  void addRecentFile(BlastFile currentFile) async {
    for (var i = 0; i < recentFiles.list.length; i++) {
      if (recentFiles.list[i].isEqualto(currentFile)) {
        recentFiles.list.removeAt(i);
        break;
      }
    }

    recentFiles.list.insert(0, currentFile);

    if (recentFiles.list.length > 5) {
      recentFiles.list.removeLast();
    }
    _saveRecentFiles();
  }

  void _saveRecentFiles() async {
    var prefs = await _prefs;
    var jsonRecent = recentFiles.toString();
    await prefs.setString('recentFiles', jsonRecent);
  }
}
